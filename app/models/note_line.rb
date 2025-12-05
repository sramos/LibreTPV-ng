class NoteLine < ApplicationRecord
  belongs_to :note
  belongs_to :product, optional: true

  validates :product_name, presence: true
  validates :product_price, presence: true
  validates :product_vat, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :quantity, presence: true
  validates :note, presence: true
  # Remove next comment after migrating old data
  #validate :avoid_changes_on_closed_note

  before_validation :set_product_values
  before_destroy :validate_destroy, prepend: true

  def total_amount
    product_price * quantity * (1 - discount)
  end

  def tax_base
    total_amount / (1 + product_vat)
  end

  def total_vat
    total_amount - tax_base
  end

  def product_vat_value
    100.0 * product_vat.to_f
  end

  def product_vat_value=new_value
    self.product_vat = new_value.to_f / 100.0
  end

  def discount_value
    100.0 * discount.to_f
  end

  def discount_value=new_value
    self.discount = new_value.to_f / 100.0
  end

  private

  # Set product values if there is no previously defined
  def set_product_values
    if product
      self.product_name = product.name if product_name.blank?
      self.product_vat = product.vat.rate if product_vat.blank?
      # For supplier note lines, product_price is the purchase price
      # and should be calculated by discounting vat from selling price
      self.product_price = product_price_from_product if product_price.blank?
    end
    self.product_name ||= 'N/A'
  end

  def product_price_from_product
    product.price||0.0
  end

  def avoid_changes_on_closed_note
    if note&.closed
      errors.add(:base, I18n.t('errors.notes.closed_note'))
    end
  end

  def validate_destroy
    if note&.closed
      errors.add(:base, I18n.t('errors.notes.removal_closed_note'))
      throw :abort
    end
  end
end
