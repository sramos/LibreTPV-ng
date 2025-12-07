class SupplierInvoice < Invoice
  include ::Sanitizable
  stripable :code
  upcaseable :code

  has_many :supplier_notes, class_name: 'SupplierNote', foreign_key: 'invoice_id'
  belongs_to :supplier
  # Supplier invoices could have many supplier_notes
  

  validates :supplier, presence: true
  validate :code_must_be_unique_for_supplier

  def total_vat
    Rails.logger.error "[SupplierInvoice.total_vat] Could not find supplier_note for invoice #{id}" if supplier_note.nil?
    supplier_note&.total_vat
  end

  def tax_base
    Rails.logger.error "[SupplierInvoice.tax_base] Could not find supplier_note for invoice #{id}" if supplier_note.nil?
    supplier_note&.tax_base
  end

  private

  def code_must_be_unique_for_supplier
    if SupplierInvoice.where(supplier_id: supplier_id, code: code).where.not(id: id).exists?
      errors.add(:code, I18n.t('errors.supplier_invoices.unique_for_supplier'))
    end
  end
end
