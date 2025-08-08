class NoteLine < ApplicationRecord
  belongs_to :note
  belongs_to :product

  validates :product_name, presence: true
  validates :product_price, presence: true
  validates :product_vat, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :quantity, presence: true
  validates :note, presence: true
end
