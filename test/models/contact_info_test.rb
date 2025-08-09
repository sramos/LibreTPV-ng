require 'test_helper'

class ContactInfoTest < ActiveSupport::TestCase
  test "should not save contact_info without contactable" do
    contact_info = ContactInfo.new(
      address: 'Calle Ejemplo 123',
      postal_code: '28001',
      province: 'Madrid',
      country: 'España',
      phone: '+34 912 345 678',
      contact: 'Juan Pérez',
      email: 'contact@example.com',
      web: 'www.example.com'
    )
    contact_info.valid?
    assert contact_info.errors[:contactable].any?
  end

  test "should save contact_info with valid client" do
    contact_info = ContactInfo.new(
      address: 'Calle Ejemplo 123',
      postal_code: '28001',
      province: 'Madrid',
      country: 'España',
      phone: '+34 912 345 678',
      contact: 'Juan Pérez',
      email: 'contact@example.com',
      web: 'www.example.com',
      contactable: clients(:one)
    )
    assert contact_info.valid?
  end

  test "should save contact_info with valid supplier" do
    contact_info = ContactInfo.new(
      address: 'Calle Ejemplo 123',
      postal_code: '28001',
      province: 'Madrid',
      country: 'España',
      phone: '+34 912 345 678',
      contact: 'Juan Pérez',
      email: 'contact@example.com',
      web: 'www.example.com',
      contactable: suppliers(:one)
    )
    assert contact_info.valid?
  end

  test "should have valid associations" do
    contact_info = contact_infos(:one)
    assert_respond_to contact_info, :contactable
  end
end
