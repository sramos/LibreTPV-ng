require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test "should not save payment without invoice" do
    payment = Payment.new
    payment.valid?
    assert payment.errors[:invoice].any?
  end

  test "should not save payment without payment_type" do
    payment = Payment.new
    payment.valid?
    assert payment.errors[:payment_type].any?
  end

  test "should not save payment without amount" do
    payment = Payment.new
    payment.valid?
    assert payment.errors[:amount].any?
  end

  test "should have one invoice" do
    payment = payments(:one)
    assert_respond_to payment, :invoice
  end

  test "should have one payment_type" do
    payment = payments(:one)
    assert_respond_to payment, :payment_type
  end

  test "should have valid associations" do
    payment = payments(:one)
    assert_not_nil payment.invoice
    assert_not_nil payment.payment_type
  end
end
