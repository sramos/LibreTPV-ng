class Author < ApplicationRecord
  has_many :product_authors
  has_many :products, through: :product_authors

  validates :name, presence: true, uniqueness: true
end
