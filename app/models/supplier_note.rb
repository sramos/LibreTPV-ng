class SupplierNote < Note
  belongs_to :supplier
  has_many :note_lines, class_name: 'SupplierNoteLine', foreign_key: 'note_id', dependent: :destroy

  validates :supplier, presence: true
  validates_inclusion_of :deposit, in: [ true, false ]

  private

  # Returns 1 for purchases notes
  def product_increment
    1
  end
end
