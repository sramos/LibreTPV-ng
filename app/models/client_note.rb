class ClientNote < Note
  belongs_to :client

  validates :client, presence: true
  validates :deposit, presence: false
  validates :devolution_date, presence: false

  private

  # Returns -1 for sales notes
  def product_increment
    -1
  end
end
