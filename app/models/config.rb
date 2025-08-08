class Config < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
