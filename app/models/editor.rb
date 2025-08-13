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
      errors.add(:base, 'No se puede eliminar un editor que tenga productos')
      throw :abort
    end
  end
end
