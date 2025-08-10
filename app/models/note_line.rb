class NoteLine < ApplicationRecord
  belongs_to :note
  belongs_to :product

  validates :product_name, presence: true
  validates :product_price, presence: true
  validates :product_vat, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :quantity, presence: true
  validates :note, presence: true
  validate :avoid_changes_on_disabled_note

  before_validation :set_product_values, if: :product

  def total_amount
    product_price * quantity
  end

  def tax_base
    product_price * quantity / (1 + product_vat)
  end

  def total_vat
    product_price * quantity * product_vat
  end

  private

  def set_product_values
    self.product_name = product.name
    self.product_price = product.price
    self.product_vat = product.vat.rate
  end

  def avoid_changes_on_disabled_note
    if note&.closed == true
      errors.add(:base, 'No se puede modificar una nota cerrada')
    end
  end
end
