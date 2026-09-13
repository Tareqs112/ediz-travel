require "test_helper"

class Admin::TripInquiriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @inquiry = trip_inquiries(:one) # Jane Doe, jane@example.com, new
    @inquiry_two = trip_inquiries(:two) # John Smith, john@example.com, new (Wait, both are new)
    @inquiry_two.update_column(:status, "confirmed") # Make sure one is confirmed for testing
  end

  test "should block unauthenticated access" do
    get admin_trip_inquiries_url
  assert_redirected_to new_session_url
end

test "should get index" do
  sign_in_as(users(:one))

    get admin_trip_inquiries_url
    assert_response :success
    assert_match "Jane Doe", response.body
    assert_match "John Smith", response.body
  end

  test "should get index with status filter" do
    sign_in_as(users(:one))
    get admin_trip_inquiries_url(status: "new")
    assert_response :success
    assert_match "Jane Doe", response.body
    assert_no_match "John Smith", response.body
  end

  test "should get index with search query by customer name" do
    sign_in_as(users(:one))
    get admin_trip_inquiries_url(q: "Jane")
    assert_response :success
    assert_match "Jane Doe", response.body
    assert_no_match "John Smith", response.body
  end

  test "should get index with search query by email" do
    sign_in_as(users(:one))
    get admin_trip_inquiries_url(q: "john@example.com")
    assert_response :success
    assert_match "John Smith", response.body
    assert_no_match "Jane Doe", response.body
  end

  test "should get index with status filter and search combined" do
    sign_in_as(users(:one))
    get admin_trip_inquiries_url(status: "confirmed", q: "John")
    assert_response :success
    assert_match "John Smith", response.body
    
    sign_in_as(users(:one))
    sign_in_as(users(:one))
    get admin_trip_inquiries_url(status: "new", q: "John")
    assert_response :success
    assert_no_match "John Smith", response.body
    assert_no_match "Jane Doe", response.body
  end

  test "should show trip inquiry" do
    sign_in_as(users(:one))
    get admin_trip_inquiry_url(@inquiry)
    assert_response :success
  end

  test "should update trip inquiry status" do
    sign_in_as(users(:one))
    patch admin_trip_inquiry_url(@inquiry), params: {
      trip_inquiry: { status: "contacted" }
    }
    assert_redirected_to admin_trip_inquiry_url(@inquiry, locale: nil)
    @inquiry.reload
    assert_equal "contacted", @inquiry.status
  end

  test "should not update to invalid status" do
    sign_in_as(users(:one))
    patch admin_trip_inquiry_url(@inquiry), params: {
      trip_inquiry: { status: "invalid_status" }
    }
    assert_response :unprocessable_entity
    @inquiry.reload
    assert_not_equal "invalid_status", @inquiry.status
  end
end
