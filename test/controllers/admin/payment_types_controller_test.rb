require "test_helper"

class Admin::PaymentTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user_one)
    @payment_type = payment_types(:card)
  end

  test "should get index" do
    get admin_payment_types_path
    assert_response :success
  end

  test "should get new" do
    get new_admin_payment_type_path
    assert_response :success
  end

  test "should create payment_type" do
    assert_difference('PaymentType.count') do
      post admin_payment_types_path, params: { payment_type: { name: 'New Payment Type', cash: true, active: true } }
    end

    assert_redirected_to admin_payment_types_path
  end

  test "should get edit" do
    get edit_admin_payment_type_path(@payment_type)
    assert_response :success
  end

  test "should update payment_type" do
    patch admin_payment_type_path(@payment_type), params: { payment_type: { name: @payment_type.name, cash: @payment_type.cash, active: @payment_type.active } }
    assert_redirected_to admin_payment_types_path
  end

  test "should destroy payment_type" do
    @payment_type = PaymentType.create!(name: 'Temporal Test', cash: false, active: true)
    assert_difference('PaymentType.count', -1) do
      delete admin_payment_type_path(@payment_type)
    end

    assert_redirected_to admin_payment_types_path
  end

  test "should not create payment_type without name" do
    assert_no_difference('PaymentType.count') do
      post admin_payment_types_path, params: { payment_type: { name: '', cash: true, active: true } }
    end
  end

  test "should create payment_type as non-cash by default" do
    assert_difference('PaymentType.count') do
      post admin_payment_types_path, params: { payment_type: { name: 'Credit Card', active: true } }
    end
    payment_type = PaymentType.order(:created_at).last
    assert_not payment_type.cash
  end
end
