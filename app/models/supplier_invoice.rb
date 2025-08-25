class SupplierInvoice < Invoice
  include ::Sanitizable
  stripable :code
  upcaseable :code

  belongs_to :supplier

  validates :supplier, presence: true
  validate :code_must_be_unique_for_supplier

  private

  def code_must_be_unique_for_supplier
    if SupplierInvoice.where(supplier_id: supplier_id, code: code).where.not(id: id).exists?
      errors.add(:code, I18n.t('errors.supplier_invoices.unique_for_supplier'))
    end
  end
end
