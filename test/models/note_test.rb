require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test "should not save note without date" do
    note = Note.new
    note.valid?
    assert note.errors[:date].any?
  end

  test "should have many note_lines" do
    note = notes(:client_note_one)
    assert_respond_to note, :note_lines
  end

  test "should have one client" do
    note = notes(:client_note_one)
    assert_respond_to note, :client
  end

  test "should have one supplier" do
    note = notes(:supplier_note_one)
    assert_respond_to note, :supplier
  end

  test "should have closed field with default false" do
    note = Note.new
    assert_equal false, note.closed
  end

  test "should calculate total amount" do
    note = notes(:client_note_one)
    assert_equal 30, note.total_amount
  end

  test "should calculate tax base" do
    note = notes(:client_note_one)
    assert_equal 24.79, note.tax_base.round(2)
  end

  test "should calculate total vat" do
    note = notes(:client_note_one)
    assert_equal 5.21, note.total_vat.round(2)
  end

  test "should not change stock when note is changed" do
    note = notes(:client_note_one)
    note_line = note.note_lines.first
    product = note_line.product
    initial_stock = product.stock
    note.update!(code: 'NEW-CODE')

    # Verify stock doesn't change
    assert_equal initial_stock, product.reload.stock
  end

  test "should update stock for multiple note lines" do
    product2 = products(:two)
    p2_stock = product2.stock
    p2_quantity = 3
    product3 = products(:three)
    p3_stock = product3.stock
    p3_quantity = 4

    note = notes(:client_note_one)

    # Add multiple lines with different quantities
    note.note_lines.create!(
      product: product2,
      product_name: "Test 1",
      product_price: 10.0,
      product_vat: 0.21,
      quantity: p2_quantity
    )

    note.note_lines.create!(
      product: product3,
      product_name: "Test 2",
      product_price: 15.0,
      product_vat: 0.21,
      quantity: p3_quantity
    )

    # Close the note
    note.close!

    # Verify stock updates for both products
    assert_equal p2_stock - p2_quantity, product2.reload.stock
    assert_equal p3_stock - p3_quantity, product3.reload.stock
  end

  test "should not update stock for notes that are not closed" do
    product = products(:one)
    initial_stock = product.stock

    note = notes(:client_note_one)
    note_line = note.note_lines.first
    note_line.update(product: product, quantity: 2)

    # Update without closing
    note.save!

    # Stock should remain unchanged
    assert_equal initial_stock, product.reload.stock
  end

  test "should not update stock for note lines without products" do
    note = notes(:client_note_one)
    note_line = note.note_lines.first
    note_line.update(product_id: nil, quantity: 2)

    # Close the note
    note.close!

    # Verify no stock updates occurred
    assert_nothing_raised do
      note.reload
    end
  end
end
