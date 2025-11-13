class Note < ApplicationRecord
  include ::Sanitizable
  stripable :code

  has_many :note_lines, dependent: :destroy
  belongs_to :client, optional: true
  belongs_to :supplier, optional: true
  belongs_to :invoice, optional: true

  validates :date, presence: true
  validate :validate_update, on: :update

  after_commit :update_products_stock
  before_destroy :validate_destroy, prepend: true

  def close!
    update(closed: true)
  end

  def total_amount
    note_lines.map(&:total_amount).inject(0, &:+)
  end

  def tax_base
    note_lines.map(&:tax_base).inject(0, &:+)
  end

  def total_vat
    note_lines.map(&:total_vat).inject(0, &:+)
  end

  def note_lines_count
    note_lines.count
  end

  private

  # Returns -1 for sales notes and 1 for purchases notes
  def product_increment
    0
  end

  def update_products_stock
    if saved_change_to_closed?
      multiplier = closed? ? 1 : -1
      note_lines.each do |note_line|
        if product = note_line.product
          product.update(stock: product.stock + (note_line.quantity * product_increment * multiplier))
        end
      end
    end
  end

  def validate_update
    # If the note is closed, it cannot be modified
    if closed && !closed_changed?
      errors.add(:base, I18n.t('errors.notes.closed_note'))
    # A note can be opened again only if there is no invoice or it is open
    elsif closed_changed? && !closed && invoice.present?
      errors.add(:base, I18n.t('errors.notes.reopen_with_invoice'))
    end
  end

  def validate_destroy
    if closed?
      errors.add(:base, I18n.t('errors.notes.removal_closed_note'))
      throw :abort
    end
  end
end
