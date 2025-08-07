class Product < ApplicationRecord
  belongs_to :product_type
  has_one :vat, through: :product_type
  has_many :note_lines
  has_many :notes, through: :note_lines

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true
  validates :product_type, presence: true
  validates :code, presence: true, uniqueness: true
end