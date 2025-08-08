require 'test_helper'

class PaymentTypeTest < ActiveSupport::TestCase
  test "should not save payment_type without name" do
    payment_type = PaymentType.new
    payment_type.valid?
    assert payment_type.errors[:name].any?
  end

  test "should not save payment_type with duplicate name" do
    PaymentType.create!(name: 'Transferencia')
    duplicate = PaymentType.new(name: 'Transferencia')
    duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "should save payment_type with valid name" do
    payment_type = PaymentType.new(name: 'Transferencia')
    assert payment_type.valid?
  end

  test "should have valid associations" do
    payment_type = payment_types(:one)
    assert_respond_to payment_type, :payments
  end

  test "should have many payments" do
    payment_type = payment_types(:one)
    assert_equal 1, payment_type.payments.count
  end
end
