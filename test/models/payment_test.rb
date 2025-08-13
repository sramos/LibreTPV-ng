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
    payment = payments(:payment_one)
    assert_respond_to payment, :invoice
  end

  test "should have one payment_type" do
    payment = payments(:payment_one)
    assert_respond_to payment, :payment_type
  end

  test "should update invoice paid status after payment creation" do
    invoice = invoices(:one)
    invoice.update!(paid: false)

    payment = Payment.create!(
      amount: invoice.total_amount,
      date: Date.today,
      invoice: invoice,
      payment_type: payment_types(:card)
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
      payment_type: payment_types(:card)
    )

    invoice.reload
    assert_not invoice.paid

    payment.update!(amount: invoice.total_amount)
    invoice.reload
    assert invoice.paid
  end

  test "should have valid associations" do
    payment = payments(:payment_one)
    assert_not_nil payment.invoice
    assert_not_nil payment.payment_type
  end

  test "should prevent destroying cash payment after cash closure" do
    # Create a cash payment
    cash_payment = payments(:payment_two)
    assert cash_payment.payment_type.cash

    # Create a cash closure after the payment date
    Cash.create!(
      date: cash_payment.date + 1.day,
      amount: 100
    )

    assert_not cash_payment.destroy
    assert_equal ["No se puede eliminar un pago en metálico tras un cierre de caja"], cash_payment.errors[:base]
    assert Payment.exists?(cash_payment.id)
  end

  test "should allow destroying cash payment after cash closure" do
    # Create a cash payment
    cash_payment = payments(:payment_two)
    assert cash_payment.payment_type.cash

    # Create a cash closure before the payment date
    Cash.create!(
      date: cash_payment.date - 1.day,
      amount: 100
    )

    assert cash_payment.destroy
    assert_not Payment.exists?(cash_payment.id)
  end

  test "should allow destroying non-cash payment before cash closure" do
    # Create a non-cash payment
    non_cash_payment = payments(:payment_one)
    assert_not non_cash_payment.payment_type.cash

    # Create a cash closure
    Cash.create!(
      date: non_cash_payment.date - 1.day,
      amount: 100
    )

    assert non_cash_payment.destroy
    assert_not Payment.exists?(non_cash_payment.id)
  end
end
