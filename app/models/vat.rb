class Vat < ApplicationRecord
  has_many :product_types
  has_many :products, through: :product_types

  validates :name, presence: true, uniqueness: true
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
