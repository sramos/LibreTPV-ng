require 'test_helper'

class NoteLineTest < ActiveSupport::TestCase
  test "should not save note_line without note_id" do
    note_line = NoteLine.new
    note_line.valid?
    assert note_line.errors[:note].any?
  end

  test "should not save note_line without product_name" do
    note_line = NoteLine.new
    note_line.valid?
    assert note_line.errors[:product_name].any?
  end

  test "should not save note_line without product_price" do
    note_line = NoteLine.new
    note_line.valid?
    assert note_line.errors[:product_price].any?
  end

  test "should not save note_line without product_vat" do
    note_line = NoteLine.new
    note_line.valid?
    assert note_line.errors[:product_vat].any?
  end

  test "should have quantity field with default 1" do
    note_line = NoteLine.new
    assert_equal 1, note_line.quantity
  end

  test "should not update line if note is disabled" do
    note_line = note_lines(:one)
    note_line.note.update(closed: true)
    note_line.update(quantity: 2)
    assert note_line.errors[:base].any?
  end
end
