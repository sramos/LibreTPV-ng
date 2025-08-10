class ClientInvoice < Invoice
  belongs_to :client

  validates :client, presence: true
  validate :code_must_be_unique
  validate :avoid_vat_and_retentions

  private

  def avoid_vat_and_retentions
    if vat.present? || income_retention.present?
      errors.add(:base, 'vat or income_retention cannot be present at client invoice')
    end
  end

  def code_must_be_unique
    if ClientInvoice.where(code: code).where.not(id: id).exists?
      errors.add(:code, 'must be unique')
    end
  end
end
