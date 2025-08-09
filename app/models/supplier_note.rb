class SupplierNote < Note
  belongs_to :supplier

  validates :supplier, presence: true
  validates_inclusion_of :deposit, in: [ true, false ]
  validates :devolution_date, presence: true, if: :deposit
end
