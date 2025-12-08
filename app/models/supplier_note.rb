class SupplierNote < Note
  belongs_to :supplier
  has_many :note_lines, class_name: 'SupplierNoteLine', foreign_key: 'note_id', dependent: :destroy

  validates :supplier, presence: true
  validates_inclusion_of :deposit, in: [ true, false ]
  validate :related_invoice_is_from_same_supplier

  private

  # Returns 1 for purchases notes
  def product_increment
    1
  end

  def related_invoice_is_from_same_supplier
    if invoice && invoice.supplier_id != supplier_id
      errors.add(:base, I18n.t('errors.supplier_notes.wrong_supplier_invoice'))
    end
    throw :abort unless errors.empty?
  end
end
