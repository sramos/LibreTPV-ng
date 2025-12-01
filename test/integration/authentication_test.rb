require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "should redirect unauthenticated users to sign in page" do
    get root_path
    assert_redirected_to new_user_session_path
  end

  test "should allow authenticated users to access home page" do
    sign_in users(:user_one)
    get root_path
    assert_response :success
  end

  test "should redirect unauthenticated users from sales section" do
    get sales_clients_path
    assert_redirected_to new_user_session_path
    
    get sales_client_notes_path
    assert_redirected_to new_user_session_path
    
    get sales_cash_index_path
    assert_redirected_to new_user_session_path
  end

  test "should allow authenticated users with proper access to sales section" do
    sign_in users(:user_one)
    get sales_clients_path
    assert_response :success
    
    get sales_client_notes_path
    assert_response :success
    
    get sales_cash_index_path
    assert_response :success
  end

  test "should redirect unauthenticated users from products section" do
    get products_products_path
    assert_redirected_to new_user_session_path
    
    get products_suppliers_path
    assert_redirected_to new_user_session_path
    
    get products_supplier_notes_path
    assert_redirected_to new_user_session_path
  end

  test "should allow authenticated users with proper access to products section" do
    sign_in users(:user_one)
    get products_products_path
    assert_response :success
    
    get products_suppliers_path
    assert_response :success
    
    get products_supplier_notes_path
    assert_response :success
  end

  test "should redirect unauthenticated users from admin section" do
    get admin_users_path
    assert_redirected_to new_user_session_path
    
    get admin_configs_path
    assert_redirected_to new_user_session_path
    
    get admin_authors_path
    assert_redirected_to new_user_session_path
  end

  test "should allow authenticated users with proper access to admin section" do
    sign_in users(:user_one)
    get admin_users_path
    assert_response :success
    
    get admin_configs_path
    assert_response :success
    
    get admin_authors_path
    assert_response :success
  end

  test "should sign out users and redirect to home page" do
    sign_in users(:user_one)
    get root_path
    assert_response :success
    
    delete destroy_user_session_path
    assert_redirected_to root_path
    
    get root_path
    assert_redirected_to new_user_session_path
  end
end
