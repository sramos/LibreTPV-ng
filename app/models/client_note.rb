class ClientNote < Note
  belongs_to :client

  validates :client, presence: true
  validates :deposit, presence: false
  validates :devolution_date, presence: false
end
