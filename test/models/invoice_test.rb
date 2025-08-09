require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  test "should not save invoice without code" do
    invoice = Invoice.new
    invoice.valid?
    assert invoice.errors[:code].any?
  end

  test "should not save invoice with note and vat/tax" do
    invoice = Invoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
      note: notes(:one),
      vat: 21.0,
      tax: 10.0
    )
    invoice.valid?
    assert invoice.errors[:base].any?
  end

  test "should save invoice with note only" do
    invoice = Invoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
      note: notes(:one)
    )
    assert invoice.valid?
  end

  test "should save invoice with vat and tax only" do
    invoice = Invoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
      vat: 21.0,
      tax: 10.0
    )
    assert invoice.valid?
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

  test "should have one note" do
    invoice = invoices(:one)
    assert_respond_to invoice, :note
  end

  test "should have valid associations" do
    invoice = invoices(:one)
    assert_not_nil invoice.note
  end
end
