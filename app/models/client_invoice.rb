class ClientInvoice < Invoice
  belongs_to :client

  validates :client, presence: true
  validate :code_must_be_unique
  validate :avoid_vat_and_retentions

  before_commit :set_invoice_code, on: :create

  private

  def avoid_vat_and_retentions
    if vat.present? || income_retention.present?
      errors.add(:base, I18n.t('errors.client_invoices.vat_or_income_retention'))
    end
  end

  def code_must_be_unique
    if ClientInvoice.where(code: code).where.not(id: id).exists?
      errors.add(:code, I18n.t('errors.global.must_be_unique'))
    end
  end

  def set_invoice_code
    self.code = Config.next_invoice_code if code.blank?
  end
end
