require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  test "should not save config without name" do
    config = Config.new
    config.valid?
    assert config.errors[:name].any?
  end

  test "should not save config with duplicate name" do
    Config.create!(name: 'company_address', value: 'My Company address')
    duplicate = Config.new(name: 'company_address', value: 'Other Company address')
    duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "should save config with valid name and value" do
    config = Config.new(name: 'company_address', value: 'My Company address')
    assert config.valid?
  end

  test "should have valid attributes" do
    config = configs(:one)
    assert config.name.present?
    assert config.value.present?
  end

  test "should generate consecutive invoice numbers" do
    # First call should start from 0
    number1 = Config.next_invoice_number
    assert_equal "1", number1

    # Second call should be consecutive
    number2 = Config.next_invoice_number
    assert_equal "2", number2

    # Third call should continue the sequence
    number3 = Config.next_invoice_number
    assert_equal "3", number3
  end

  test "should handle existing invoice count" do
    # Create a config with existing value
    Config.create!(name: 'COMPANY_INVOICES_COUNT', value: '42')

    # Next number should be 43
    number = Config.next_invoice_number
    assert_equal "43", number
  end

  test "should handle blank invoice count" do
    # Create a config with blank value
    Config.create!(name: 'COMPANY_INVOICES_COUNT', value: '')

    # First number should be 1
    number = Config.next_invoice_number
    assert_equal "1", number
  end

  test "should handle nil invoice count" do
    # Delete existing config if any
    Config.find_by(name: 'COMPANY_INVOICES_COUNT')&.destroy
    
    # First number should be 1
    number = Config.next_invoice_number
    assert_equal "1", number
  end

  test "should create config record if it doesn't exist" do
    # Delete existing config if any
    Config.find_by(name: 'COMPANY_INVOICES_COUNT')&.destroy

    # First call should create the record and start from 1
    number = Config.next_invoice_number
    assert_equal "1", number
    
    # Verify the record was created
    config = Config.find_by(name: 'COMPANY_INVOICES_COUNT')
    assert config.present?
    assert_equal "1", config.value
  end
end
