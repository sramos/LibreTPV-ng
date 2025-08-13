class Client < ApplicationRecord
  has_one :contact_info, as: :contactable, required: false
  has_many :notes

  validates :name, presence: true
  validates :code_id, presence: true, uniqueness: true
  validates :discount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  before_destroy :validate_destroy, prepend: true

  private

  def validate_destroy
    if notes.any?
      errors.add(:base, 'No se puede eliminar un cliente que tenga creados albaranes.')
      throw :abort
    end
  end
end
