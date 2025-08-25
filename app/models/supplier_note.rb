class SupplierNote < Note
  belongs_to :supplier

  validates :supplier, presence: true
  validates_inclusion_of :deposit, in: [ true, false ]

  private

  # Returns 1 for purchases notes
  def product_increment
    1
  end
end
