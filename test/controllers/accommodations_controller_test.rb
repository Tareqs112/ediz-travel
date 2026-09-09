require "test_helper"

class AccommodationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hotel = accommodations(:one)
    @chalet = accommodations(:two)
  end

  test "should get index" do
    get accommodations_url
    assert_response :success
    assert_match @hotel.name, response.body
    assert_match @chalet.name, response.body
  end

  test "should get index with category filter" do
    get accommodations_url(type: "hotel")
    assert_response :success
    assert_match @hotel.name, response.body
    assert_no_match @chalet.name, response.body
  end

  test "should show accommodation" do
    get accommodation_url(@hotel)
    assert_response :success
    assert_match @hotel.name, response.body
  end

  test "should return 404 for inactive accommodation" do
    @hotel.update!(active: false)
    get accommodation_url(@hotel)
    assert_response :not_found
  end

  test "should return 404 for nonexistent accommodation" do
    get accommodation_url("nonexistent-slug")
    assert_response :not_found
  end
end
