class Invoice < ApplicationRecord
  belongs_to :note
  has_many :payments

  validates :code, presence: true
  validates :date, presence: true
  validates :total, presence: true
  validate :code_must_be_unique_for_supplier

  private

  def code_must_be_unique_for_supplier
    if Invoice.joins(:note).where(note: {supplier_id: note&.supplier_id})
              .where(code: code).exists?
      errors.add(:code, 'must be unique for supplier')
    end
  end
end