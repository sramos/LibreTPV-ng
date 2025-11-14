class ClientCreditIncrementService < ApplicationService
  def call(invoice)
    # Print invoice ticket
  rescue => e
    failure(e)
  end
end
