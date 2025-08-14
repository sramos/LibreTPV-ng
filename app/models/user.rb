class User < ApplicationRecord
  include Sanitizable
  stripable :email, :name

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable,
         :lockable, :timeoutable, :trackable

  has_many :user_accesses
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP}
  validates :password, presence: true, length: { minimum: 6 }
  validates :name, presence: true

  def active_for_authentication?
    super and self.active?
  end

  def granted?(section)
    UserAccess.granted?(self, section)
  end
end
