class ClientInvoice < Invoice
  has_one :client_note, class_name: 'ClientNote', foreign_key: 'invoice_id'
  belongs_to :client

  validates :client, presence: true
  validate :code_must_be_unique
  validate :avoid_vat_and_retentions

  before_commit :set_invoice_code, on: :create

  def total_vat
    Rails.logger.error "[ClientInvoice.total_vat] Could not find client_note for invoice #{id}" if client_note.nil?
    client_note&.total_vat
  end

  def tax_base
    Rails.logger.error "[ClientInvoice.tax_base] Could not find client_note for invoice #{id}" if client_note.nil?
    client_note&.tax_base
  end

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
