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

  test "should clean up name before validation" do
    editor = Editor.new(name: "  editorial001 ")
    assert editor.valid?
    assert_equal "EDITORIAL001", editor.name
  end

  test "should strip and uppercase name" do
    editor = Editor.new(name: "  editorial001 ")
    assert editor.valid?
    assert_equal "EDITORIAL001", editor.name
  end

  test "should prevent destroying editor with products" do
    editor = editors(:one)
    assert editor.products.any?

    assert_not editor.destroy
    assert_equal ["No se puede eliminar un editor que tenga productos"], editor.errors[:base]
    assert Editor.exists?(editor.id)
  end

  test "should allow destroying editor without products" do
    editor = editors(:one)

    # Remove all products from the editor
    editor.products.destroy_all
    assert_equal 0, editor.products.count

    assert editor.destroy
    assert_not Editor.exists?(editor.id)
  end
end
