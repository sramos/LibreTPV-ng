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

  test "should prevent destroying payment_type with payments" do
    payment_type = payment_types(:one)
    assert payment_type.payments.any?

    assert_not payment_type.destroy
    assert_equal ["No se puede eliminar una forma de pago que tenga pagos asociados"], payment_type.errors[:base]
    assert PaymentType.exists?(payment_type.id)
  end

  test "should allow destroying payment_type without payments" do
    payment_type = payment_types(:one)

    # Remove all payments from the payment_type
    payment_type.payments.destroy_all
    assert_equal 0, payment_type.payments.count

    assert payment_type.destroy
    assert_not PaymentType.exists?(payment_type.id)
  end
end
