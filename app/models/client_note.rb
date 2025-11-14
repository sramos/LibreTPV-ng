class ClientNote < Note
  belongs_to :client
  belongs_to :invoice, optional: true

  validates :client, presence: true
  validates :deposit, presence: false
  validates :devolution_date, presence: false

  scope :open, -> { where(closed: false) }
  scope :closed, -> { where(closed: true) }

  def total_amount
    note_lines.sum('product_price * quantity * (1 - discount)')
  end

  def tax_base
    note_lines.sum('product_price * quantity * (1 - discount) / (1 + product_vat)')
  end

  def total_vat
    total_amount - tax_base
  end

  def initialize_invoice
    ClientInvoice.new(client_id: client_id, date: DateTime.now,
                      total_amount: total_amount)
  end

  def create_and_pay_invoice(attrs)
    invoice = nil
    payment_type = PaymentType.find_by(id: attrs[:payment_type_id], active: true) if attrs[:payment_type_id]
    if payment_type && invoice_id.blank? && !closed?
      invoice = ClientInvoice.create(client_id: client_id,
                                     date: DateTime.now,
                                     total_amount: total_amount)
      invoice.payment.create(date: date,
                             amount: total_amount,
                             payment_type_id: attrs[:payment_type_id]) if invoice.errors.blank?
    end
    return invoice
  end

  private

  # Returns -1 for sales notes
  def product_increment
    -1
  end

  def self.clear_empty_notes
    ClientNote.where(closed: false).each do |note|
      note.destroy if note.note_lines.empty?
    end
  end
end
