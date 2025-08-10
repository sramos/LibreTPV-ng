class Note < ApplicationRecord
  has_many :note_lines, dependent: :destroy
  belongs_to :client, optional: true
  belongs_to :supplier, optional: true
  belongs_to :invoice, optional: true

  validates :code, presence: true, uniqueness: { scope: :supplier_id }
  validates :date, presence: true

  after_commit :update_products_stock, if: :closed?

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
end
