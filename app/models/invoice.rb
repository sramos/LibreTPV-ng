class Invoice < ApplicationRecord
  include ::Sanitizable
  stripable :code

  has_many :payments
  has_many :notes

  validates :code, presence: true
  validates :date, presence: true
  validates :total_amount, presence: true

  before_destroy :validate_destroy, prepend: true

  def paid_amount
    payments.sum(:amount)
  end

  def pending_payment
    total_amount - paid_amount
  end
  
  private

  def validate_destroy
    if payments.any?
      errors.add(:base, I18n.t('errors.invoices.removal_with_payments'))
      throw :abort
    end
  end
end
