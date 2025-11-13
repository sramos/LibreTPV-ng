class ClientCreditIncrementService < ApplicationService
  def call(client, amount)
    client.update(credit: client.credit + amount)
    if client.errors.empty?
      Cash.create(amount: amount, date: Time.now, cash_count: false, comments: "Incremento de crédito de #{client.name}")
      success(client)
    else
      failure(client.errors)
    end
  rescue => e
    failure(e)
  end
end
