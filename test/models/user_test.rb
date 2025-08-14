require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should have valid fixtures" do
    user = users(:user_one)
    user.password = "password"
    user.password_confirmation = "password"

    assert user.valid?
  end
  test "should have valid email format" do
    user = users(:user_one)
    user.password = "password"
    user.password_confirmation = "password"
    assert user.valid?

    user.email = "invalid_email"
    user.valid?
    assert user.errors[:email].any?

    user.email = "valid@example.com"
    assert user.valid?
  end

  test "should require password" do
    user = User.new(email: "test@example.com", name: "Test User")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "should require minimum password length" do
    user = User.new(email: "test@example.com", name: "Test User", password: "12345")
    assert_not user.valid?
    assert user.errors[:password].any?

    user.password = "123456"
    assert user.valid?
  end

  test "should require name" do
    user = User.new(email: "test@example.com")
    assert_not user.valid?
    assert user.errors[:name].any?
  end

  test "should clean email and name before validation" do
    user = User.new(email: " TEST@example.com ", name: " Test User ")
    user.valid?
    assert_equal "test@example.com", user.email
  end

  test "should be active by default" do
    user = User.new(email: "test@example.com", name: "Test User", password: "123456")
    assert user.active?
  end

  test "should be active when active is true" do
    user = User.new(email: "test@example.com", name: "Test User", password: "123456", active: true)
    assert user.active?
  end

  test "should not be active when active is false" do
    user = User.new(email: "test@example.com", name: "Test User", password: "123456", active: false)
    assert_not user.active?
  end

  test "should authenticate with correct credentials" do
    user = users(:user_one)
    assert user.valid_password?("password")
    assert_not user.valid_password?("wrong_password")
  end

  test "should check section access" do
    user = users(:user_one)
    assert user.granted?(:sales)
    assert user.granted?(:products)
    assert_not user.granted?(:invalid_section)
  end

  test "should not be authenticable when inactive" do
    user = users(:user_one)
    user.update(active: false)
    assert_not user.active_for_authentication?
  end

  test "should be authenticable when active" do
    user = users(:user_one)
    assert user.active_for_authentication?
  end
end

class UserAccessTest < ActiveSupport::TestCase
  test "should have valid fixtures" do
    assert user_accesses(:access_sales).valid?
  end

  test "should require section" do
    user_access = UserAccess.new(user: users(:user_one))
    assert_not user_access.valid?
    assert user_access.errors[:section].any?
  end

  test "should require user" do
    user_access = UserAccess.new(section: "sales")
    assert_not user_access.valid?
    assert user_access.errors[:user].any?
  end

  test "should clean section before validation" do
    user_access = UserAccess.new(user: users(:user_one), section: " sales ")
    user_access.valid?
    assert_equal "sales", user_access.section
  end

  test "should prevent duplicate sections for same user" do
    user = users(:user_one)
    user_access = UserAccess.create(user: user, section: "one_section")
    assert user_access.valid?

    duplicate = UserAccess.new(user: user, section: "one_section")
    assert_not duplicate.valid?
    assert duplicate.errors[:section].any?
  end

  test "should allow different sections for same user" do
    user = users(:user_one)
    user_access = UserAccess.create(user: user, section: "one_section")
    assert user_access.valid?

    different_section = UserAccess.new(user: user, section: "another_section")
    assert different_section.valid?
  end

  test "should check access for user" do
    user = users(:user_one)
    assert UserAccess.granted?(user, "sales")
    assert_not UserAccess.granted?(user, "invalid_section")
  end
end
