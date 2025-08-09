class ClientInvoice < Invoice
  belongs_to :client

  validates :note, presence: true
  validates :client, presence: true
  validate :code_must_be_unique

  private

  def code_must_be_unique
    if ClientInvoice.where(code: code).where.not(id: id).exists?
      errors.add(:code, 'must be unique')
    end
  end
end
