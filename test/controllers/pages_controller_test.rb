require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_url
    assert_response :success
  end

  test "should get plan_your_trip" do
    get plan_your_trip_url
    assert_response :success
  end

  test "should get airport_transfer" do
    get airport_transfer_url
    assert_response :success
  end
end
