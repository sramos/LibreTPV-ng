class ProductType < ApplicationRecord
  belongs_to :vat
  has_many :products
  has_many :product_subtypes

  validates :name, presence: true, uniqueness: true
  validates :vat, presence: true
end
