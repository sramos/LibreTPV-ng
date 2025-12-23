class Client < ApplicationRecord
  include ::Deactivatable
  include ::Sanitizable
  stripable :name

  has_one :contact_info, as: :contactable, required: false
  has_many :notes
  has_many :client_invoices
  has_many :client_notes, through: :client_invoices
  has_many :note_lines, through: :client_notes
  has_many :products, through: :note_lines

  validates :name, presence: true
  validates :discount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  before_destroy :validate_destroy, prepend: true

  def discount_value
    discount * 100
  end

  def name_nif
    output  = name
    output += ' - NIF: ' + code_id unless code_id.blank? || code_id == 'N/A'
    return output
  end

  private

  def validate_destroy
    if notes.any?
      errors.add(:base, I18n.t('errors.clients.removal_with_existing_notes'))
      throw :abort
    end
  end
end
