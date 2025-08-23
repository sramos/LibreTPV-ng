require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  test "should prevent destroying client with notes" do
    client = clients(:one)

    assert_not client.destroy
    assert_equal [I18n.t('errors.clients.removal_with_existing_notes')], client.errors[:base]
    assert Client.exists?(client.id)
  end

  test "should allow destroying client without notes" do
    client = clients(:one)

    # Ensure client has no notes
    client.notes.destroy_all
    assert_equal 0, client.notes.count

    assert client.destroy
    assert_not Client.exists?(client.id)
  end

  test "should validate presence of name" do
    client = Client.new
    assert_not client.valid?
    assert client.errors[:name].any?
  end

  test "should validate discount range" do
    client = Client.new(
      name: "Test Client",
      code_id: "CLI001",
      discount: 0.5
    )
    assert client.valid?

    client.discount = 0.0
    assert client.valid?

    client.discount = 1.0
    assert client.valid?

    client.discount = -0.1
    assert_not client.valid?
    assert client.errors[:discount].any?

    client.discount = 1.1
    assert_not client.valid?
    assert client.errors[:discount].any?
  end
end
