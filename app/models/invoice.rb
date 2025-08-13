class Invoice < ApplicationRecord
  has_many :payments
  has_many :notes

  validates :code, presence: true
  validates :date, presence: true
  validates :base_amount, presence: true
  validates :total_amount, presence: true

  before_destroy :validate_destroy

  private

  def validate_destroy
    if payments.any?
      errors.add(:base, 'No se puede eliminar una factura que tenga pagos realizados')
      throw :abort
    end
  end
end
