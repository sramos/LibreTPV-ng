require "test_helper"

class Admin::ProductSubtypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user_one)
    @product_type = product_types(:product_type_one)
    @product_subtype = product_subtypes(:product_subtype_one)
  end

  test "should get index" do
    get admin_product_type_product_subtypes_path(@product_type)
    assert_response :success
  end

  test "should get new" do
    get new_admin_product_type_product_subtype_path(@product_type)
    assert_response :success
  end

  test "should create product_subtype" do
    assert_difference('ProductSubtype.count') do
      post admin_product_type_product_subtypes_path(@product_type), params: { product_subtype: { name: 'New Product Subtype', description: 'Test description', default: false, active: true } }
    end

    assert_redirected_to admin_product_type_product_subtypes_path(@product_type)
  end

  test "should get edit" do
    get edit_admin_product_type_product_subtype_path(@product_type, @product_subtype)
    assert_response :success
  end

  test "should update product_subtype" do
    patch admin_product_type_product_subtype_path(@product_type, @product_subtype), params: { product_subtype: { name: @product_subtype.name, description: @product_subtype.description, default: @product_subtype.default, active: @product_subtype.active } }
    assert_redirected_to admin_product_type_product_subtypes_path(@product_type)
  end

  test "should destroy product_subtype" do
    assert_difference('ProductSubtype.count', -1) do
      delete admin_product_type_product_subtype_path(@product_type, @product_subtype)
    end

    assert_redirected_to admin_product_type_product_subtypes_path(@product_type)
  end

  test "should not create product_subtype without name" do
    assert_no_difference('ProductSubtype.count') do
      post admin_product_type_product_subtypes_path(@product_type), params: { product_subtype: { name: '', description: 'Test description', default: false, active: true } }
    end
  end

  test "should create product_subtype associated with product_type" do
    assert_difference('ProductSubtype.count') do
      post admin_product_type_product_subtypes_path(@product_type), params: { product_subtype: { name: 'Associated Subtype', description: 'Test description', active: true } }
    end
    product_subtype = ProductSubtype.order(:created_at).last
    assert_equal @product_type, product_subtype.product_type
  end
end
