class SupplierInvoice < Invoice
  belongs_to :supplier

  validates :supplier, presence: true
  validates :expiration_date, presence: true
  validate :code_must_be_unique_for_supplier

  private

  def code_must_be_unique_for_supplier
    if SupplierInvoice.where(supplier_id: supplier_id, code: code).where.not(id: id).exists?
      errors.add(:code, 'must be unique for supplier')
    end
  end
end
