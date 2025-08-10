class Product < ApplicationRecord
  has_many :product_authors
  has_many :authors, through: :product_authors
  has_many :note_lines
  has_many :notes, through: :note_lines
  belongs_to :product_type
  belongs_to :product_subtype, optional: true
  belongs_to :editor, optional: true
  has_one :vat, through: :product_type

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true
  validates :product_type, presence: true
  validates :code, presence: true, uniqueness: true

  def tax_base
    price / (1 + vat.rate)
  end
end
