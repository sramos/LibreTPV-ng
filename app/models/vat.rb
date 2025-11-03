class Vat < ApplicationRecord
  include ::Sanitizable
  stripable :name

  has_many :product_types
  has_many :products, through: :product_types

  validates :name, presence: true, uniqueness: true
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  before_destroy :validate_destroy, prepend: true

  def rate_value
    100.0 * rate.to_f
  end

  def rate_value=new_value
    self.rate = new_value.to_f / 100.0
  end

  private

  def validate_destroy
    if product_types.any?
      errors.add(:base, I18n.t('errors.vats.removal_with_existing_product_types'))
      throw :abort
    end
  end
end
