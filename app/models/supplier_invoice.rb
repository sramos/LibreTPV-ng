class SupplierInvoice < Invoice
  include ::Sanitizable
  stripable :code
  upcaseable :code

  belongs_to :supplier
  has_many :supplier_notes, class_name: 'SupplierNote', foreign_key: 'invoice_id'
  has_many :note_lines, through: :supplier_notes, source: :note_lines

  validates :supplier, presence: true
  validate :code_must_be_unique_for_supplier

  def total_vat
    value = 0.0
    supplier_notes.each{|n| value += n.total_vat}
    return value
  end

  def tax_base
    value = 0.0
    supplier_notes.each{|n| value += n.tax_base}
    return value
  end

  def supplier_note_copy
    deposit = supplier_notes.where(deposit: true).any?
    note = SupplierNote.new( supplier_id: supplier_id, date: DateTime.now, closed: false, deposit: deposit )
    transaction do
      note_lines.each do |nl|
        note.note_lines << nl.dup
      end
      note.save
    end
    return note
  end

  private

  def code_must_be_unique_for_supplier
    if SupplierInvoice.where(supplier_id: supplier_id, code: code).where.not(id: id).exists?
      errors.add(:code, I18n.t('errors.supplier_invoices.unique_for_supplier'))
    end
  end
end
