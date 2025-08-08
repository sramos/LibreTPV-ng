class Payment < ApplicationRecord
  belongs_to :invoice
  belongs_to :payment_type

  validates :amount, presence: true
  validates :date, presence: true
end
