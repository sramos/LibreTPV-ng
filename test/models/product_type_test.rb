require 'test_helper'

class ProductTypeTest < ActiveSupport::TestCase
  test "should not save product_type without name" do
    product_type = ProductType.new
    product_type.valid?
    assert product_type.errors[:name].any?
  end

  test "should not save product_type with duplicate name" do
    product_type = ProductType.create!(name: 'Test', vat: vats(:one))
    duplicate = ProductType.new(name: 'Test')
    duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "should not save product_type without vat" do
    product_type = ProductType.new
    product_type.valid?
    assert product_type.errors[:vat].any?
  end

  test "should have many products" do
    product_type = product_types(:one)
    assert_respond_to product_type, :products
  end

  test "should have one vat" do
    product_type = product_types(:one)
    assert_respond_to product_type, :vat
  end

  test "should have vat association" do
    product_type = ProductType.create!(name: 'Test', vat: vats(:one))
    assert_not_nil product_type.vat
  end
end
