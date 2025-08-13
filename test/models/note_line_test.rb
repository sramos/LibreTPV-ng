require 'test_helper'

class NoteLineTest < ActiveSupport::TestCase
  test "should not save note_line without note_id" do
    note_line = NoteLine.new
    note_line.valid?
    assert note_line.errors[:note].any?
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

  test "should prevent changes on closed note" do
    note_line = note_lines(:one)
    note_line.note.update(closed: true)

    # Attempt to change various fields
    note_line.quantity = 22

    assert_not note_line.save
    assert_equal [I18n.t('errors.notes.closed_note')], note_line.errors[:base]

    # Verify no changes were actually made
    note_line.reload
    assert_not_equal 22, note_line.quantity
  end

  test "should allow changes on open note" do
    note_line = note_lines(:one)

    # Verify note is not closed
    assert_not note_line.note.closed?

    # Attempt to change fields
    note_line.quantity = 22

    assert note_line.save

    # Verify changes were saved
    note_line.reload
    assert_equal 22, note_line.quantity
  end
end
