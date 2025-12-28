class ClientInvoice < Invoice
  has_one :client_note, class_name: 'ClientNote', foreign_key: 'invoice_id'
  has_many :note_lines, through: :client_note, source: :note_lines
  belongs_to :client

  validates :client, presence: true
  #validates :validation_hash, presence: true
  validate :code_must_be_unique
  validate :avoid_vat_and_retentions

  before_validation :set_invoice_code_and_hash, on: :create
  before_destroy :avoid_client_invoice_destroy, prepend: true

  def total_vat
    Rails.logger.error "[ClientInvoice.total_vat] Could not find client_note for invoice #{id}" if client_note.nil?
    client_note&.total_vat.round(2)
  end

  def tax_base
    Rails.logger.error "[ClientInvoice.tax_base] Could not find client_note for invoice #{id}" if client_note.nil?
    client_note&.tax_base.round(2)
  end

  # Invoice types
  # F1: Fatura completa/ordinaria. Estándar para transacciones B2B y B2C con todos los datos (NIF, etc.). ART. 6, 7.2 Y 7.3 DEL RD 1619/2012
  # F2: Fatura simplificada. Usada para transacciones B2C de menor importe y sin info destinatario. ART. 6.1.D) RD 1619/2012
  # R1: Factura rectificativa (Art 80.1 y 80.2 y error fundado en derecho)
  # R2: Factura rectificativa (Art. 80.3)
  # R3: Factura rectificativa (Art. 80.4)
  # R4: Factura rectificativa (Resto)
  # R5: Factura rectificativa en facturas simplificadas
  # F3: Factura emitida en sustitución de facturas simplificadas facturadas y declaradas
  def type_code
    client.is_b2b ? 'F1' : 'F2'
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

  def set_invoice_code_and_hash
    self.code = Config.next_invoice_code if code.blank?
  end

  def avoid_client_invoice_destroy
    errors.add(:base, I18n.t('errors.client_invoices.removal_not_allowed'))
    throw :abort
  end
end
