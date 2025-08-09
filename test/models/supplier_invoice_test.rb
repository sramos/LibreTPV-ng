require 'test_helper'

class SupplierInvoiceTest < ActiveSupport::TestCase
  test "should not save supplier_invoice without supplier" do
    supplier_invoice = SupplierInvoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121
    )
    supplier_invoice.valid?
    assert supplier_invoice.errors[:supplier].any?
  end

  test "should not save supplier_invoice with duplicate code for same supplier" do
    supplier = suppliers(:one)

    SupplierInvoice.create!(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
      supplier: supplier,
      note: notes(:two)
    )

    duplicate = SupplierInvoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
      supplier: supplier,
      note: notes(:two)
    )
    duplicate.valid?
    assert duplicate.errors[:code].any?
  end

  test "should save supplier_invoice with valid supplier and note" do
    supplier_invoice = SupplierInvoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
      supplier: suppliers(:one),
      note: notes(:two)
    )
    assert supplier_invoice.valid?
  end

  test "should save supplier_invoice with vat/tax" do
    supplier_invoice = SupplierInvoice.new(
      code: 'INV001-01',
      date: Date.today,
      base_amount: 100,
      total_amount: 121,
      supplier: suppliers(:one),
      vat: 21.0,
      tax: 10.0
    )
    assert supplier_invoice.valid?
  end

  test "should have valid associations" do
    supplier_invoice = invoices(:two)
    assert_respond_to supplier_invoice, :supplier
    assert_respond_to supplier_invoice, :payments
  end
end
