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
end
