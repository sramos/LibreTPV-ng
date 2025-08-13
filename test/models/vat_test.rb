require 'test_helper'

class VatTest < ActiveSupport::TestCase
  test "should not save vat without name" do
    vat = Vat.new
    vat.valid?
    assert vat.errors[:name].any?
  end

  test "should not save vat with duplicate name" do
    vat = Vat.create!(name: 'Test', rate: 0.21)
    duplicate = Vat.new(name: 'Test')
    duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "should not save vat with rate outside 0-1 range" do
    vat = Vat.new(rate: 1.5)
    vat.valid?
    assert vat.errors[:rate].any?

    vat = Vat.new(rate: -0.1)
    vat.valid?
    assert vat.errors[:rate].any?
  end

  test "should save vat with valid rate" do
    vat = Vat.new(name: 'Test', rate: 0.21)
    assert vat.valid?
  end

  test "should have many product_types" do
    vat = vats(:vat_one)
    assert_respond_to vat, :product_types
  end

  test "should have many products through product_types" do
    vat = vats(:vat_one)
    assert_respond_to vat, :products
  end

  test "should prevent destroying vat with product_types" do
    vat = vats(:vat_one)
    assert vat.product_types.any?

    assert_not vat.destroy
    assert_equal [I18n.t('errors.vats.removal_with_existing_product_types')], vat.errors[:base]
    assert Vat.exists?(vat.id)
  end

  test "should allow destroying vat without product_types" do
    vat = vats(:vat_three)

    # Remove all product_types from the vat
    vat.product_types.destroy_all
    assert_equal 0, vat.product_types.count

    assert vat.destroy
    assert_not Vat.exists?(vat.id)
  end
end
