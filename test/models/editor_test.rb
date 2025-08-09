require 'test_helper'

class EditorTest < ActiveSupport::TestCase
  test "should not allow multiple editors with same name" do
    name = 'Editorial Test001'
    Editor.create!(name: name)
    editor = Editor.new(name: name)
    editor.valid?
    assert_equal "has already been taken", editor.errors[:name].first
  end

  test "should save editor with valid name" do
    editor = Editor.new(name: 'Editorial Test002')
    assert editor.valid?
  end

  test "should have many products" do
    editor = editors(:one)
    assert_respond_to editor, :products
  end

  test "should have valid associations" do
    editor = editors(:one)
    assert editor.products.any?
  end
end
