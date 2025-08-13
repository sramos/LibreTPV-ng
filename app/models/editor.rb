class Editor < ApplicationRecord
  include ::Sanitizable
  stripable :name
  upcaseable :name

  has_many :products

  validates :name, presence: true, uniqueness: true
  before_destroy :validate_destroy, prepend: true

  private

  def validate_destroy
    if products.any?
      errors.add(:base, I18n.t('errors.editors.removal_with_existing_products'))
      throw :abort
    end
  end
end
