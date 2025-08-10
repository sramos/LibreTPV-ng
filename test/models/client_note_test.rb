require 'test_helper'

class ClientNoteTest < ActiveSupport::TestCase
  test "should not save client_note without client" do
    client_note = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      closed: false
    )
    client_note.valid?
    assert client_note.errors[:client].any?
  end

  test "should save client_note with valid client" do
    client_note = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      closed: false,
      client: clients(:one)
    )
    assert client_note.valid?
  end

  test "should not save client_note with duplicate code" do
    client_note = ClientNote.create!(
      code: 'CLI001',
      date: Date.today,
      closed: false,
      client: clients(:one)
    )
    duplicate = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      closed: false,
      client: clients(:two)
    )
    duplicate.valid?
    assert duplicate.errors[:code].any?
  end

  test "should save client_note without deposit" do
    client_note = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      closed: false,
      client: clients(:one)
    )
    assert client_note.valid?
  end

  test "should reduce stock when client note is closed" do
    note = notes(:client_note_one)
    note_line = note.note_lines.first
    product = note_line.product
    initial_stock = product.stock
    note_line.update(product: product, quantity: 2)

    # Verify stock doesn't change before closing
    assert_equal initial_stock, product.reload.stock

    # Close the note
    note.close!

    # Verify stock was updated
    expected_stock = initial_stock - 2 # -1 * 2 since it's a sales note
    assert_equal expected_stock, product.reload.stock
  end

  test "should increase stock when reopening client note" do
    client_note = notes(:client_note_one)
    note_line = client_note.note_lines.first
    product = note_line.product
    initial_stock = product.stock
    quantity = note_line.quantity

    # Close the note
    client_note.close!
    # Verify stock was reduced
    assert_equal initial_stock - quantity, product.reload.stock

    # Reopen the note
    client_note.closed = false
    assert client_note.save
    # Verify stock was restored
    assert_equal initial_stock, product.reload.stock
  end

  test "should save client_note without devolution_date" do
    client_note = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      closed: false,
      client: clients(:one)
    )
    assert client_note.valid?
  end

  test "should have valid associations" do
    client_note = notes(:client_note_one)
    assert_respond_to client_note, :client
    assert_respond_to client_note, :note_lines
  end

  test "should have valid type" do
    client_note = notes(:client_note_one)
    assert_equal 'ClientNote', client_note.type
  end
end
