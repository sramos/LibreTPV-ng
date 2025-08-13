class Payment < ApplicationRecord
  belongs_to :invoice
  belongs_to :payment_type

  validates :amount, presence: true, numericality: { not_equal_to: 0 }
  validates :date, presence: true

  after_commit :update_invoice_paid_status
  before_destroy :validate_destroy

  private

  def update_invoice_paid_status
    invoice.update(paid: invoice.payments.sum(:amount) >= invoice.total_amount)
  end

  def validate_destroy
    last_cash_close = Cash.where("date >= ?", date).last if payment_type.cash
    if last_cash_close
      errors.add(:base, 'No se puede eliminar un pago en metálico tras un cierre de caja')
      throw :abort
    end
  end
end
