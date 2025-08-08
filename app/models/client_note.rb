class ClientNote < Note
  belongs_to :client

  validates :client, presence: true
end
