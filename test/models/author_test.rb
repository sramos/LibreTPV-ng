require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  test "should not save author with duplicated name" do
    Author.create!(name: 'Autor001')
    author = Author.new(name: 'Autor001')
    author.valid?
    assert author.errors[:name].any?
  end

  test "should save author with valid name" do
    author = Author.new(name: 'Autor002')
    assert author.valid?
  end

  test "should have many products" do
    author = authors(:one)
    assert_respond_to author, :products
  end

  test "should have many product_authors" do
    author = authors(:one)
    assert_respond_to author, :product_authors
  end

  test "should have valid associations" do
    author = authors(:one)
    assert author.products.any?
    assert author.product_authors.any?
  end
end
