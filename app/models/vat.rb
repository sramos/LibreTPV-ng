class Vat < ApplicationRecord
  has_many :product_types
  has_many :products, through: :product_types

  validates :name, presence: true, uniqueness: true
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  before_destroy :validate_destroy, prepend: true

  private

  def validate_destroy
    if product_types.any?
      errors.add(:base, 'No se puede eliminar un IVA que tenga tipos de productos asociados')
      throw :abort
    end
  end
end
