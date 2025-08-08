require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  test "should not save invoice without code" do
    invoice = Invoice.new
    invoice.valid?
    assert invoice.errors[:code].any?
  end

  test "should not save invoice with duplicate code for same supplier" do
    # Usar fixtures directamente
    note_one = notes(:one)
    note_two = notes(:two)

    Invoice.create!(code: 'INV001-01', date: Date.today, total: 100, note: note_one)
    duplicate = Invoice.new(code: 'INV001-01', date: Date.today, total: 100, note: note_one)
    duplicate.valid?
    assert duplicate.errors[:code].any?

    # Verificar que el mismo código es válido para un proveedor diferente
    other_invoice = Invoice.new(code: 'INV001-01', date: Date.today, total: 100, note: note_two)
    assert other_invoice.valid?
  end

  test "should not save invoice without date" do
    invoice = Invoice.new
    invoice.valid?
    assert invoice.errors[:date].any?
  end

  test "should not save invoice without total" do
    invoice = Invoice.new
    invoice.valid?
    assert invoice.errors[:total].any?
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
