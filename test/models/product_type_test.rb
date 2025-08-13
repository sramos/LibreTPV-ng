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
    product_type = product_types(:product_type_one)
    assert_respond_to product_type, :products
  end

  test "should have one vat" do
    product_type = product_types(:product_type_one)
    assert_respond_to product_type, :vat
  end

  test "should have vat association" do
    product_type = ProductType.create!(name: 'Test', vat: vats(:one))
    assert_not_nil product_type.vat
  end

  test "should prevent destroying product_type with products" do
    product_type = product_types(:product_type_one)
    assert product_type.products.any?

    assert_not product_type.destroy
    assert_equal ["No se puede eliminar un tipo de producto que tenga productos asociados"], product_type.errors[:base]
    assert ProductType.exists?(product_type.id)
  end

  test "should allow destroying product_type without products" do
    product_type = product_types(:product_type_three)
    product_count = product_type.products.count
    assert product_count == 0

    # Remove all products from the product_type
    product_type.products.destroy_all
    assert_equal 0, product_type.products.count

    assert product_type.destroy
    assert_not ProductType.exists?(product_type.id)
  end

  test "should destroy product_subtypes when product_type is destroyed" do
    product_type = product_types(:product_type_three)
    subtype_count = product_type.product_subtypes.count
    assert subtype_count > 0

    # Remove all products to allow product_type destruction
    product_type.products.destroy_all

    assert product_type.destroy
    assert_not ProductType.exists?(product_type.id)

    # Verify all subtypes were destroyed
    assert_equal 0, ProductSubtype.where(product_type_id: product_type.id).count
  end
end
