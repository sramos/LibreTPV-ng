class UserAccess < ApplicationRecord
  include Sanitizable
  stripable :section

  belongs_to :user

  validates :section, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true

  def self.granted?(user, section)
    user.user_accesses.exists?(section: section)
  end
end
