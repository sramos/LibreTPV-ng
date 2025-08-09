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

  test "should update invoice paid status after payment creation" do
    invoice = invoices(:one)
    invoice.update!(paid: false)
    
    payment = Payment.create!(
      amount: invoice.total_amount,
      date: Date.today,
      invoice: invoice,
      payment_type: payment_types(:one)
    )
    
    invoice.reload
    assert invoice.paid
  end

  test "should update invoice paid status after payment update" do
    invoice = invoices(:one)
    invoice.update!(paid: false)
    
    payment = Payment.create!(
      amount: invoice.total_amount/10.0,
      date: Date.today,
      invoice: invoice,
      payment_type: payment_types(:one)
    )
    
    invoice.reload
    assert_not invoice.paid
    
    payment.update!(amount: invoice.total_amount)
    invoice.reload
    assert invoice.paid
  end

  test "should have valid associations" do
    payment = payments(:one)
    assert_not_nil payment.invoice
    assert_not_nil payment.payment_type
  end
end
