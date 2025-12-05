class Supplier < ApplicationRecord
  include ::Deactivatable
  include ::Sanitizable
  stripable :name

  has_one :contact_info, as: :contactable, required: false
  accepts_nested_attributes_for :contact_info, update_only: true
  has_many :notes

  validates :name, presence: true
  validates :discount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  before_destroy :validate_destroy, prepend: true

  def discount_value
    discount * 100
  end

  def discount_value=(value)
    self.discount = value.to_f / 100.0
  end

  private

  def validate_destroy
    if notes.any?
      errors.add(:base, I18n.t('errors.suppliers.removal_with_existing_notes'))
      throw :abort
    end
  end
end
