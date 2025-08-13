require 'test_helper'

class SupplierTest < ActiveSupport::TestCase
  test "should prevent destroying supplier with notes" do
    supplier = suppliers(:one)

    assert_not supplier.destroy
    assert_equal ["No se puede eliminar un proveedor que tenga creados albaranes."], supplier.errors[:base]
    assert Supplier.exists?(supplier.id)
  end

  test "should allow destroying supplier without notes" do
    supplier = suppliers(:one)

    # Ensure supplier has no notes
    supplier.notes.destroy_all
    assert_equal 0, supplier.notes.count

    assert supplier.destroy
    assert_not Supplier.exists?(supplier.id)
  end

  test "should validate presence of name" do
    supplier = Supplier.new
    assert_not supplier.valid?
    assert supplier.errors[:name].any?
  end

  test "should validate presence of code_id" do
    supplier = Supplier.new(name: "Test Supplier")
    assert_not supplier.valid?
    assert supplier.errors[:code_id].any?
  end

  test "should validate code_id uniqueness" do
    existing_supplier = suppliers(:one)
    supplier = Supplier.new(
      name: "Test Supplier",
      code_id: existing_supplier.code_id
    )
    assert_not supplier.valid?
    assert supplier.errors[:code_id].any?
  end

  test "should validate discount range" do
    supplier = Supplier.new(
      name: "Test Supplier",
      code_id: "SUP001",
      discount: 0.5
    )
    assert supplier.valid?

    supplier.discount = -0.1
    assert_not supplier.valid?
    assert supplier.errors[:discount].any?

    supplier.discount = 1.1
    assert_not supplier.valid?
    assert supplier.errors[:discount].any?
  end

  test "should have many notes" do
    supplier = suppliers(:one)
    assert_respond_to supplier, :notes
  end

  test "should have one contact_info" do
    supplier = suppliers(:one)
    assert_respond_to supplier, :contact_info
  end
end
