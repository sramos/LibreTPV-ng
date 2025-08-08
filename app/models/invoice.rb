class Invoice < ApplicationRecord
  belongs_to :note, optional: true

  has_many :payments

  validates :code, presence: true
  validates :date, presence: true
  validates :total, presence: true
  validate :avoid_note_and_vat_and_taxes

  private

  def avoid_note_and_vat_and_taxes
    if note.present? && (vat.present? || tax.present?)
      errors.add(:base, 'Note and vat/taxes cannot be present at the same time')
    end
  end
end
