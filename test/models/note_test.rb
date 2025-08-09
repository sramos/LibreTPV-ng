require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test "should not save note without code" do
    note = Note.new
    note.valid?
    assert note.errors[:code].any?
  end

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
end
