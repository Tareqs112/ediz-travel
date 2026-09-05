require "test_helper"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get destinations_url
    assert_response :success
  end

  test "should get show" do
    get destination_url("trabzon")
    assert_response :success
  end
end
