require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  test "should not save invoice without code" do
    invoice = Invoice.new
    invoice.valid?
    assert invoice.errors[:code].any?
  end

  test "should not save invoice without date" do
    invoice = Invoice.new
    invoice.valid?
    assert invoice.errors[:date].any?
  end

  test "should not save invoice without total amount" do
    invoice = Invoice.new
    invoice.valid?
    assert invoice.errors[:total_amount].any?
  end

  test "should not save invoice without base amount" do
    invoice = Invoice.new
    invoice.valid?
    assert invoice.errors[:base_amount].any?
  end

  test "should save invoice" do
    invoice = Invoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
    )
    assert invoice.valid?
  end

  test "should prevent destroying invoice with payments" do
    invoice = invoices(:one)
    assert invoice.payments.any?

    assert_not invoice.destroy
    assert_equal ["No se puede eliminar una factura que tenga pagos realizados"], invoice.errors[:base]
    assert Invoice.exists?(invoice.id)
  end

  test "should allow destroying invoice without payments" do
    invoice = invoices(:one)

    # Remove all payments from the invoice
    invoice.payments.destroy_all
    assert_equal 0, invoice.payments.count

    assert invoice.destroy
    assert_not Invoice.exists?(invoice.id)
  end
end
