class Invoice < ApplicationRecord
  has_many :payments
  has_many :notes

  validates :code, presence: true
  validates :date, presence: true
  validates :base_amount, presence: true
  validates :total_amount, presence: true
end
