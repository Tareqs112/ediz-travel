require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in_as(users(:one))
    get admin_root_url
    assert_response :success
  end

  test "should block unauthenticated access to dashboard" do
    get admin_root_url
    assert_redirected_to new_session_url
  end
end
