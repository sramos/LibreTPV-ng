class PaymentType < ApplicationRecord
  has_many :payments

  validates :name, presence: true, uniqueness: true

  before_destroy :validate_destroy, prepend: true

  scope :active, -> { where(active: true) }
  private

  def validate_destroy
    if payments.any?
      errors.add(:base, 'No se puede eliminar una forma de pago que tenga pagos asociados')
      throw :abort
    end
  end
end
