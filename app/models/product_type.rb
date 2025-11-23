class ProductType < ApplicationRecord
  include ::Deactivatable
  include ::Sanitizable
  stripable :name

  belongs_to :vat
  has_many :products
  has_many :product_subtypes, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :vat, presence: true

  before_destroy :validate_destroy, prepend: true
  after_commit :update_default_type, if: Proc.new { |record| record.active? && record.default? }

  def self.default
    find_by(active: true, default: true)
  end

  private

  def update_default_type
    ProductType.where(default: true).where.not(id: id).update_all(default: false)
  end
  
  def validate_destroy
    if products.any?
      errors.add(:base, 'No se puede eliminar un tipo de producto que tenga productos asociados')
      throw :abort
    end
  end
end
