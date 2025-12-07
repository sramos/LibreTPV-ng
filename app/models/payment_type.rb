class PaymentType < ApplicationRecord
  include ::Deactivatable
  include ::Sanitizable
  stripable :name

  has_many :payments

  validates :name, presence: true, uniqueness: true

  before_destroy :validate_destroy, prepend: true

  scope :active, -> { where(active: true) }
  
  def self.options_for_select
    active.collect { |pt| [pt.name, pt.id] }  
  end

  private

  def validate_destroy
    if payments.any?
      errors.add(:base, 'No se puede eliminar una forma de pago que tenga pagos asociados')
      throw :abort
    end
  end
end
