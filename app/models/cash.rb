class Cash < ApplicationRecord
  validates :amount, presence: true
  validates :date, presence: true
end
