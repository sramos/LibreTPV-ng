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

  test "should increase products stock when supplier note is closed" do
    note = notes(:supplier_note_one)
    note_line = note.note_lines.first
    product = note_line.product
    initial_stock = product.stock
    note_line.update(product: product, quantity: 2)

    # Verify stock doesn't change before closing
    assert_equal initial_stock, product.reload.stock

    # Close the note
    note.close!

    # Verify stock was updated
    expected_stock = initial_stock + 2 # +1 * 2 since it's a purchase note
    assert_equal expected_stock, product.reload.stock
  end

  test "should reduce stock when reopening supplier note" do
    supplier_note = notes(:supplier_note_one)
    note_line = supplier_note.note_lines.first
    product = note_line.product
    initial_stock = product.stock
    quantity = note_line.quantity

    # Close the note
    supplier_note.close!
    # Verify stock was increased
    assert_equal initial_stock + quantity, product.reload.stock

    # Reopen the note
    supplier_note.closed = false
    assert supplier_note.save
    # Verify stock was restored
    assert_equal initial_stock, product.reload.stock
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
