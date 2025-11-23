class ProductSubtype < ApplicationRecord
  include ::Deactivatable
  include ::Sanitizable
  stripable :name

  belongs_to :product_type
  has_many :products, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :product_type_id }
  validates :product_type, presence: true

  after_commit :update_default_type, if: Proc.new { |record| record.active? && record.default? }

  def self.default
    find_by(active: true, default: true)
  end

  private

  def update_default_type
    ProductSubtype.where(default: true, product_type_id: product_type_id).
                   where.not(id: id).update_all(default: false)
  end
end
