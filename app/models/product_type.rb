class ProductType < ApplicationRecord
  belongs_to :vat
  has_many :products

  validates :name, presence: true, uniqueness: true
  validates :vat, presence: true
end
