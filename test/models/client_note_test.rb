require 'test_helper'

class ClientNoteTest < ActiveSupport::TestCase
  test "should not save client_note without client" do
    client_note = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      active: true
    )
    client_note.valid?
    assert client_note.errors[:client].any?
  end

  test "should save client_note with valid client" do
    client_note = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      active: true,
      client: clients(:one)
    )
    assert client_note.valid?
  end

  test "should not save client_note with duplicate code" do
    client_note = ClientNote.create!(
      code: 'CLI001',
      date: Date.today,
      active: true,
      client: clients(:one)
    )
    duplicate = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      active: true,
      client: clients(:two)
    )
    duplicate.valid?
    assert duplicate.errors[:code].any?
  end

  test "should save client_note without deposit" do
    client_note = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      active: true,
      client: clients(:one)
    )
    assert client_note.valid?
  end

  test "should save client_note without devolution_date" do
    client_note = ClientNote.new(
      code: 'CLI001',
      date: Date.today,
      active: true,
      client: clients(:one)
    )
    assert client_note.valid?
  end

  test "should have valid associations" do
    client_note = notes(:one)
    assert_respond_to client_note, :client
    assert_respond_to client_note, :note_lines
  end

  test "should have valid type" do
    client_note = notes(:one)
    assert_equal 'ClientNote', client_note.type
  end
end
