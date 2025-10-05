require "test_helper"

class ClientNotesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get client_notes_url
    assert_response :success
  end

  test "should get new" do
    get new_client_note_url
    assert_response :success
  end
end
