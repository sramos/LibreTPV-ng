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

  test "should clean up name before validation" do
    author = Author.new(name: "  autor001 ")
    assert author.valid?
    assert_equal "AUTOR001", author.name
  end

  test "should strip and uppercase name" do
    author = Author.new(name: "  autor001 ")
    assert author.valid?
    assert_equal "AUTOR001", author.name
  end

  test "should rename author without reassigning products" do
    author = authors(:one)
    new_name = "NEW AUTHOR"
    product_authors = author.product_authors.count
    
    assert_no_difference 'Author.count' do
      author.rename(new_name)
    end
    
    assert_equal new_name.upcase, author.reload.name
    assert_equal product_authors, ProductAuthor.where(author_id: author.id).count
  end

  test "should reassign products to existing author when renaming" do
    author = authors(:one)
    a1_name = author.name
    a1 = ProductAuthor.where(author_id: author.id).count
    existing_author = authors(:two)
    a2 = ProductAuthor.where(author_id: existing_author.id).count
    
    author.rename(existing_author.name, true)

    assert_nil Author.find_by(name: a1_name)
    assert_equal (a1+a2), ProductAuthor.where(author_id: existing_author.id).count
  end
end
