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
end
