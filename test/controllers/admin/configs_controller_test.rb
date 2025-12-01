require "test_helper"

class Admin::ConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user_one)
    @config = configs(:one)
  end

  test "should get index" do
    get admin_configs_path
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_config_path(@config)
    assert_response :success
  end

  test "should update config" do
    patch admin_config_path(@config), params: { config: { name: @config.name, value: 'updated_value' } }
    assert_redirected_to admin_configs_path
  end

  test "should not update config with invalid data" do
    patch admin_config_path(@config), params: { config: { name: '', value: '' } }
    assert_response :unprocessable_entity
  end
end
