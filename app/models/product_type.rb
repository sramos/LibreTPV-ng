class ProductType < ApplicationRecord
  include ::Sanitizable
  stripable :name

  belongs_to :vat
  has_many :products
  has_many :product_subtypes, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :vat, presence: true

  before_destroy :validate_destroy, prepend: true

  scope :active, -> { where(active: true).order(:name) }

  def self.default
    find_by(active: true, default: true)
  end

  private

  def validate_destroy
    if products.any?
      errors.add(:base, 'No se puede eliminar un tipo de producto que tenga productos asociados')
      throw :abort
    end
  end
end
