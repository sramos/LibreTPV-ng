class ProductSubtype < ApplicationRecord
  belongs_to :product_type
  has_many :products, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :product_type_id }
  validates :product_type, presence: true
end
