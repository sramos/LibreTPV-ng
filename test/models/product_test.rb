require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test "should not save product without name" do
    product = Product.new
    product.valid?
    assert product.errors[:name].any?
  end

  test "should not save product without price" do
    product = Product.new
    product.valid?
    assert product.errors[:price].any?
  end

  test "should not save product with negative price" do
    product = Product.new(name: 'Price test', code: 'price_test',
                          product_type: product_types(:product_type_one),
                          price: -1)
    product.valid?
    assert product.errors[:price].any?
  end

  test "should not save product without product_type" do
    product = Product.new
    product.valid?
    assert product.errors[:product_type].any?
  end

  test "should not save product without unique code" do
    product = Product.create!(name: 'Test', price: 10, stock: 5, code: 'TEST123', product_type: product_types(:product_type_one))
    duplicate = Product.new(code: 'TEST123')
    duplicate.valid?
    assert duplicate.errors[:code].any?
  end

  test "should have vat through product_type" do
    product = products(:one)
    assert_not_nil product.vat
  end

  test "should have many note_lines" do
    product = products(:one)
    assert_respond_to product, :note_lines
  end

  test "should have many notes through note_lines" do
    product = products(:one)
    assert_respond_to product, :notes
  end
end
