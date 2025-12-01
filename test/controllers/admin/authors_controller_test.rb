require "test_helper"

class Admin::AuthorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user_one)
    @author = authors(:one)
  end

  test "should get index" do
    get admin_authors_path
    assert_response :success
  end

  test "should get new" do
    get new_admin_author_path
    assert_response :success
  end

  test "should create author" do
    assert_difference('Author.count') do
      post admin_authors_path, params: { author: { name: 'New Author', active: true } }
    end

    assert_redirected_to admin_authors_path
  end

  
  test "should get edit" do
    get edit_admin_author_path(@author)
    assert_response :success
  end

  test "should update author" do
    patch admin_author_path(@author), params: { author: { name: @author.name, active: @author.active } }
    assert_redirected_to admin_authors_path
  end

  test "should destroy author" do
    @author = authors(:deletable_author)
    assert_difference('Author.count', -1) do
      delete admin_author_path(@author)
    end

    assert_redirected_to admin_authors_path
  end

  test "should get author products" do
    get products_admin_author_path(@author)
    assert_response :success
  end
end
