class PaymentType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end