require 'test_helper'

class ClientInvoiceTest < ActiveSupport::TestCase
  test "should not save client_invoice without client" do
    client_invoice = ClientInvoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
      vat: 21.0,
      tax: 10.0
    )
    client_invoice.valid?
    assert client_invoice.errors[:client].any?
  end

  test "should save client_invoice with valid client and note" do
    client_invoice = ClientInvoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
      client: clients(:one),
      note: notes(:one)
    )
    assert client_invoice.valid?
  end

  test "should have valid associations" do
    client_invoice = invoices(:one)
    assert_respond_to client_invoice, :client
    assert_respond_to client_invoice, :payments
  end
end
