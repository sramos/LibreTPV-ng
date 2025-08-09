class Supplier < ApplicationRecord
  has_one :contact_info, as: :contactable, required: false

  validates :name, presence: true
  validates :code_id, presence: true, uniqueness: true
  validates :discount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
