class SupplierNote < Note
  belongs_to :supplier

  validates :supplier, presence: true
end
