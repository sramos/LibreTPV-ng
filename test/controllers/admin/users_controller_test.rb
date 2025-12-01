require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user_one)
    @user = users(:user_two)
  end

  test "should get index" do
    get admin_users_path
    assert_response :success
  end

  test "should get new" do
    get new_admin_user_path
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post admin_users_path, params: { user: { name: 'New User', email: 'new@example.com', password: 'password123', active: true } }
    end

    assert_redirected_to admin_users_path
  end

  test "should get edit" do
    get edit_admin_user_path(@user)
    assert_response :success
  end

  # test "should update user" do
  #   patch admin_user_path(@user), params: { user: { name: 'Updated Name', email: @user.email, active: @user.active } }
  #   puts "User errors: #{@user.errors.full_messages}" if @user.errors.any?
  #   assert_redirected_to admin_users_path
  # end

  test "should destroy user" do
    @user = User.create!(name: 'Usuario Temporal Test', email: 'temp@test.com', password: 'password123', active: true)
    assert_difference('User.count', -1) do
      delete admin_user_path(@user)
    end

    assert_redirected_to admin_users_path
  end

  test "should not create user with invalid email" do
    assert_no_difference('User.count') do
      post admin_users_path, params: { user: { name: 'Invalid User', email: 'invalid_email', password: 'password123', active: true } }
    end
  end

  test "should not create user without password" do
    assert_no_difference('User.count') do
      post admin_users_path, params: { user: { name: 'No Password User', email: 'test@example.com', active: true } }
    end
  end
end
