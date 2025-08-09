class SupplierInvoice < Invoice
  belongs_to :supplier

  validates :supplier, presence: true
  validates :expiration_date, presence: true
  validate :code_must_be_unique_for_supplier
  validate :note_or_vat_and_taxes

  private

  def code_must_be_unique_for_supplier
    if SupplierInvoice.where(supplier_id: supplier_id, code: code).where.not(id: id).exists?
      errors.add(:code, 'must be unique for supplier')
    end
  end

  def note_or_vat_and_taxes
    if note.nil? && (vat.blank? || tax.blank?)
      errors.add(:note, 'or vat and taxes must be present')
    end
  end
end
