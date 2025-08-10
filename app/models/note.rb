class Note < ApplicationRecord
  has_many :note_lines, dependent: :destroy
  belongs_to :client, optional: true
  belongs_to :supplier, optional: true
  belongs_to :invoice, optional: true

  validates :code, presence: true, uniqueness: { scope: :supplier_id }
  validates :date, presence: true
  validate :validate_update, on: :update

  after_commit :update_products_stock, if: :closed?
  before_destroy :validate_destroy, prepend: true

  def close!
    update(closed: true)
  end

  private

  # Returns -1 for sales notes and 1 for purchases notes
  def product_increment
    0
  end

  def update_products_stock
    note_lines.each do |note_line|
      if product = note_line.product
        product.update(stock: product.stock + (note_line.quantity * product_increment))
      end
    end
  end

  def validate_update
    # If the note is closed, it cannot be modified
    if closed && !closed_changed?
      errors.add(:base, 'No se puede modificar un albarán cerrado')
    # A note can be opened again only if there is no invoice or it is open
    elsif closed_changed? && !closed && invoice.present?
      errors.add(:base, 'No se puede reabrir un albarán que tenga factura emitida')
    end
  end

  def validate_destroy
    if closed?
      errors.add(:base, 'No se puede eliminar un albarán cerrado')
      throw :abort
    end
  end
end
