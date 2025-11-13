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
