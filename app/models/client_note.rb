class ClientNote < Note
  belongs_to :client
  has_many :note_lines, class_name: 'ClientNoteLine', foreign_key: 'note_id', dependent: :destroy

  validates :client, presence: true
  validates :deposit, presence: false
  validates :devolution_date, presence: false

  def create_and_pay_invoice(payment_type_id)
    invoice = nil
    payment_type = PaymentType.find_by(id: payment_type_id, active: true)
    invoice = ClientInvoice.new(date: DateTime.now)
    if payment_type && invoice_id.blank? && !closed?
      Invoice.transaction do
        invoice.update(client_id: client_id,
                       total_amount: total_amount)
        payment = Payment.create(date: date, amount: total_amount,
                                 invoice_id: invoice.id,
                                 payment_type: payment_type) if invoice.errors.blank?
        update(invoice_id: invoice.id, closed: true) if payment && payment.errors.blank?
        if payment.nil? || self.errors.any?
          self.errors.add(:base, 'Error al crear el pago')
          raise ActiveRecord::Rollback
        end
      end
    end
    return invoice
  end

  def self.clear_empty_notes
    ClientNote.where(closed: false).each do |note|
      note.destroy if note.note_lines.empty?
    end
  end

  private

  # Returns -1 for sales notes
  def product_increment
    -1
  end

end
