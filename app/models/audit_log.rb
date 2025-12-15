class AuditLog < ApplicationRecord
  belongs_to :object, polymorphic: true
  belongs_to :user

  validates :action, presence: true
end
