require "test_helper"

class Admin::PublishersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user_one)
    @publisher = publishers(:publisher_one)
  end

  test "should get index" do
    get admin_publishers_path
    assert_response :success
  end

  test "should get new" do
    get new_admin_publisher_path
    assert_response :success
  end

  test "should create publisher" do
    assert_difference('Publisher.count') do
      post admin_publishers_path, params: { publisher: { name: 'New Publisher', active: true } }
    end

    assert_redirected_to admin_publishers_path
  end

  test "should get edit" do
    get edit_admin_publisher_path(@publisher)
    assert_response :success
  end

  test "should update publisher" do
    patch admin_publisher_path(@publisher), params: { publisher: { name: @publisher.name, active: @publisher.active } }
    assert_redirected_to admin_publishers_path
  end

  test "should destroy publisher" do
    @publisher = Publisher.create!(name: 'Editorial Temporal Test', active: true)
    assert_difference('Publisher.count', -1) do
      delete admin_publisher_path(@publisher)
    end

    assert_redirected_to admin_publishers_path
  end

  test "should not create publisher without name" do
    assert_no_difference('Publisher.count') do
      post admin_publishers_path, params: { publisher: { name: '', active: true } }
    end
  end

  test "should create publisher as active by default" do
    assert_difference('Publisher.count') do
      post admin_publishers_path, params: { publisher: { name: 'Active Publisher' } }
    end
    publisher = Publisher.order(:created_at).last
    assert publisher.active
  end

  test "should filter publishers by name" do
    post filter_admin_publishers_path, params: { filter: { type: 'name', value: 'test' } }
    assert_redirected_to admin_publishers_path
  end
end
