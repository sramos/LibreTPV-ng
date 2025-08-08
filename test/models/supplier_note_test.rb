require 'test_helper'

class SupplierNoteTest < ActiveSupport::TestCase
  test "should not save supplier_note without supplier" do
    supplier_note = SupplierNote.new(
      code: 'SUP001',
      date: Date.today,
      active: true
    )
    supplier_note.valid?
    assert supplier_note.errors[:supplier].any?
  end

  test "should save supplier_note with valid supplier" do
    supplier_note = SupplierNote.new(
      code: 'SUP001',
      date: Date.today,
      active: true,
      supplier: suppliers(:one)
    )
    assert supplier_note.valid?
  end

  test "should have valid associations" do
    supplier_note = notes(:two)
    assert_respond_to supplier_note, :supplier
  end

  test "should have valid type" do
    supplier_note = notes(:two)
    assert_equal 'SupplierNote', supplier_note.type
  end
end
