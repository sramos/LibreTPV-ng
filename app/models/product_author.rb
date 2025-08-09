class ProductAuthor < ApplicationRecord
  belongs_to :product
  belongs_to :author

  validates :product, presence: true
  validates :author, presence: true
end
