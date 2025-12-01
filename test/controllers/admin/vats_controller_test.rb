require "test_helper"

class Admin::VatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user_one)
    @vat = vats(:vat_one)
  end

  test "should get index" do
    get admin_vats_path
    assert_response :success
  end

  test "should get new" do
    get new_admin_vat_path
    assert_response :success
  end

  test "should create vat" do
    assert_difference('Vat.count') do
      post admin_vats_path, params: { vat: { name: 'New VAT', rate: 0.21, active: true } }
    end

    assert_redirected_to admin_vats_path
  end

  test "should get edit" do
    get edit_admin_vat_path(@vat)
    assert_response :success
  end

  test "should update vat" do
    patch admin_vat_path(@vat), params: { vat: { name: @vat.name, rate: @vat.rate, active: @vat.active } }
    assert_redirected_to admin_vats_path
  end

  test "should destroy vat" do
    @vat = Vat.create!(name: 'VAT TEMPORAL TEST', rate_value: 30, active: true)
    assert_difference('Vat.count', -1) do
      delete admin_vat_path(@vat)
    end

    assert_redirected_to admin_vats_path
  end

  test "should not create vat without name" do
    assert_no_difference('Vat.count') do
      post admin_vats_path, params: { vat: { name: '', rate_value: 21, active: true } }
    end
  end

  test "should create vat with valid rate_value" do
    assert_difference('Vat.count') do
      post admin_vats_path, params: { vat: { name: 'Valid VAT', rate_value: 16, active: true } }
    end
    vat = Vat.order(:created_at).last
    assert_equal 0.16, vat.rate
  end

  test "should create vat as active by default" do
    assert_difference('Vat.count') do
      post admin_vats_path, params: { vat: { name: 'Active VAT', rate_value: 10 } }
    end
    vat = Vat.order(:created_at).last
    assert vat.active
  end
end
