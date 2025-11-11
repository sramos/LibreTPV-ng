require 'test_helper'

class PublisherTest < ActiveSupport::TestCase
  test "should not allow multiple publishers with same name" do
    name = 'Editorial Test001'
    Publisher.create!(name: name)
    publisher = Publisher.new(name: name)
    publisher.valid?
    assert_equal "has already been taken", publisher.errors[:name].first
  end

  test "should save publisher with valid name" do
    publisher = Publisher.new(name: 'Editorial Test002')
    assert publisher.valid?
  end

  test "should have many products" do
    publisher = publishers(:publisher_one)
    assert_respond_to publisher, :products
  end

  test "should have valid associations" do
    publisher = publishers(:publisher_one)
    assert publisher.products.any?
  end

  test "should clean up name before validation" do
    publisher = Publisher.new(name: "  editorial001 ")
    assert publisher.valid?
    assert_equal "EDITORIAL001", publisher.name
  end

  test "should strip and uppercase name" do
    publisher = Publisher.new(name: "  editorial001 ")
    assert publisher.valid?
    assert_equal "EDITORIAL001", publisher.name
  end

  test "should prevent destroying publisher with products" do
    publisher = publishers(:publisher_one)
    assert publisher.products.any?

    assert_not publisher.destroy
    assert_equal [I18n.t('errors.publishers.removal_with_existing_products')], publisher.errors[:base]
    assert Publisher.exists?(publisher.id)
  end

  test "should allow destroying publisher without products" do
    publisher = publishers(:publisher_empty)

    # Remove all products from the publisher
    publisher.products.destroy_all
    assert_equal 0, publisher.products.count

    assert publisher.destroy
    assert_not Publisher.exists?(publisher.id)
  end
end
