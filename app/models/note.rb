class Note < ApplicationRecord
  has_many :note_lines
  belongs_to :client, optional: true
  belongs_to :supplier, optional: true

  validates :code, presence: true, uniqueness: { scope: :supplier_id }
  validates :date, presence: true
end
