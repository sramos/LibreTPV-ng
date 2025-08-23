class Supplier < ApplicationRecord
  include ::Sanitizable
  stripable :name

  has_one :contact_info, as: :contactable, required: false
  has_many :notes

  validates :name, presence: true
  validates :discount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  before_destroy :validate_destroy, prepend: true

  private

  def validate_destroy
    if notes.any?
      errors.add(:base, I18n.t('errors.suppliers.removal_with_existing_notes'))
      throw :abort
    end
  end
end
