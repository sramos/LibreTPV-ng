require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test "should not save note without code" do
    note = Note.new
    note.valid?
    assert note.errors[:code].any?
  end

  test "should not save note with duplicate code" do
    note = Note.create!(code: 'NOTE001', date: Date.today, active: true, supplier: suppliers(:one))
    duplicate = Note.new(code: 'NOTE001', date: Date.today, active: true, supplier: suppliers(:one))
    duplicate.valid?
    assert duplicate.errors[:code].any?
  end

  test "should not save note without date" do
    note = Note.new
    note.valid?
    assert note.errors[:date].any?
  end

  test "should have many note_lines" do
    note = notes(:one)
    assert_respond_to note, :note_lines
  end

  test "should have one client" do
    note = notes(:one)
    assert_respond_to note, :client
  end

  test "should have one supplier" do
    note = notes(:one)
    assert_respond_to note, :supplier
  end

  test "should have active field with default true" do
    note = Note.new
    assert_equal true, note.active
  end
end
