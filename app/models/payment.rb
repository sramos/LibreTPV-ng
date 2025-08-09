class Payment < ApplicationRecord
  belongs_to :invoice
  belongs_to :payment_type

  validates :amount, presence: true
  validates :date, presence: true

  after_commit :update_invoice_paid_status

  private

  def update_invoice_paid_status
    invoice.update(paid: invoice.payments.sum(:amount) >= invoice.total_amount)
  end
end
