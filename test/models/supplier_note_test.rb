require 'test_helper'

class SupplierNoteTest < ActiveSupport::TestCase
  test "should not save supplier_note without supplier" do
    supplier_note = SupplierNote.new(
      code: 'SUP001',
      date: Date.today,
      closed: false,
      deposit: false
    )
    supplier_note.valid?
    assert supplier_note.errors[:supplier].any?
  end

  test "should save supplier_note with valid supplier" do
    supplier_note = SupplierNote.new(
      code: 'SUP001',
      date: Date.today,
      closed: false,
      supplier: suppliers(:one),
      deposit: false
    )
    assert supplier_note.valid?
  end

  test "should not save supplier_note with duplicate code for same supplier" do
    supplier_note = SupplierNote.create!(
      code: 'SUP001',
      date: Date.today,
      closed: false,
      supplier: suppliers(:one),
      deposit: false
    )
    duplicate = SupplierNote.new(
      code: 'SUP001',
      date: Date.today,
      closed: false,
      supplier: suppliers(:one),
      deposit: false
    )
    duplicate.valid?
    assert duplicate.errors[:code].any?
  end

  test "should save supplier_note with duplicate code for different supplier" do
    supplier_note = SupplierNote.create!(
      code: 'SUP001',
      date: Date.today,
      closed: false,
      supplier: suppliers(:one),
      deposit: false
    )
    duplicate = SupplierNote.new(
      code: 'SUP001',
      date: Date.today,
      closed: false,
      supplier: suppliers(:two),
      deposit: false
    )
    duplicate.valid?
    assert_not duplicate.errors[:code].any?
  end

  test "should not save supplier_note with deposit without devolution_date" do
    supplier_note = SupplierNote.new(
      code: 'SUP001',
      date: Date.today,
      closed: false,
      supplier: suppliers(:one),
      deposit: true
    )
    supplier_note.valid?
    assert supplier_note.errors[:devolution_date].any?
  end

  test "should save supplier_note with deposit and devolution_date" do
    supplier_note = SupplierNote.new(
      code: 'SUP001',
      date: Date.today,
      closed: false,
      supplier: suppliers(:one),
      deposit: true,
      devolution_date: Date.today + 30
    )
    assert supplier_note.valid?
  end

  test "should have valid associations" do
    supplier_note = notes(:supplier_note_one)
    assert_respond_to supplier_note, :supplier
    assert_respond_to supplier_note, :note_lines
  end

  test "should have valid type" do
    supplier_note = notes(:supplier_note_two)
    assert_equal 'SupplierNote', supplier_note.type
  end
end
