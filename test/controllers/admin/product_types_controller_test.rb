require "test_helper"

class Admin::ProductTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user_one)
    @product_type = product_types(:product_type_one)
    @vat = vats(:vat_one)
  end

  test "should get index" do
    get admin_product_types_path
    assert_response :success
  end

  test "should get new" do
    get new_admin_product_type_path
    assert_response :success
  end

  test "should create product_type" do
    assert_difference('ProductType.count') do
      post admin_product_types_path, params: { product_type: { name: 'New Product Type', vat_id: @vat.id, description: 'Test description', default: false, active: true } }
    end

    assert_redirected_to admin_product_types_path
  end

  test "should get edit" do
    get edit_admin_product_type_path(@product_type)
    assert_response :success
  end

  test "should update product_type" do
    patch admin_product_type_path(@product_type), params: { product_type: { name: @product_type.name, vat_id: @product_type.vat_id, description: @product_type.description, default: @product_type.default, active: @product_type.active } }
    assert_redirected_to admin_product_types_path
  end

  test "should destroy product_type" do
    @vat = Vat.create!(name: 'VAT TEMPORAL PT', rate: 0.35, active: true)
    @product_type = ProductType.create!(name: 'Tipo Temporal Test', vat: @vat, active: true)
    assert_difference('ProductType.count', -1) do
      delete admin_product_type_path(@product_type)
    end

    assert_redirected_to admin_product_types_path
  end

  test "should not create product_type without name" do
    assert_no_difference('ProductType.count') do
      post admin_product_types_path, params: { product_type: { name: '', vat_id: @vat.id, description: 'Test description', default: false, active: true } }
    end
  end

  test "should not create product_type without vat" do
    assert_no_difference('ProductType.count') do
      post admin_product_types_path, params: { product_type: { name: 'New Product Type', vat_id: '', description: 'Test description', default: false, active: true } }
    end
  end

  test "should create product_type as active by default" do
    assert_difference('ProductType.count') do
      post admin_product_types_path, params: { product_type: { name: 'Active Product Type', vat_id: @vat.id, description: 'Test description' } }
    end
    product_type = ProductType.order(:created_at).last
    assert product_type.active
  end
end
