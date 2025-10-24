class NoteLine < ApplicationRecord
  belongs_to :note
  belongs_to :product, optional: true

  validates :product_name, presence: true
  validates :product_price, presence: true
  validates :product_vat, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :quantity, presence: true
  validates :note, presence: true
  #validate :avoid_changes_on_disabled_note

  before_validation :set_product_values

  def total_amount
    base = product_price * quantity
    base * (1 - discount)
  end

  def tax_base
    total_amount / (1 + product_vat)
  end

  def total_vat
    total_amount - tax_base
  end

  private

  def set_product_values
    if product
      self.product_name = product.name
      self.product_price = product.price
      self.product_vat = product.vat.rate
    else
      self.product_name = 'N/A' if product_name.blank?
    end
  end

  def avoid_changes_on_disabled_note
    if note&.closed == true
      errors.add(:base, I18n.t('errors.notes.closed_note'))
    end
  end
end
