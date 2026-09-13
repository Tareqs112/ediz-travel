require "test_helper"

class Admin::BookingRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @booking_request = booking_requests(:one) # Jane Doe, jane@example.com, status: new
    @booking_request_two = booking_requests(:two) # John Smith, john@example.com, status: confirmed
  end

  test "should block unauthenticated access" do
    get admin_booking_requests_url
  assert_redirected_to new_session_url
end

test "should get index" do
  sign_in_as(users(:one))

    get admin_booking_requests_url
    assert_response :success
    assert_match "Jane Doe", response.body
    assert_match "John Smith", response.body
  end

  test "should get index with status filter" do
    sign_in_as(users(:one))
    get admin_booking_requests_url(status: "new")
    assert_response :success
    assert_match "Jane Doe", response.body
    assert_no_match "John Smith", response.body
  end

  test "should get index with search query by customer name" do
    sign_in_as(users(:one))
    get admin_booking_requests_url(q: "Jane")
    assert_response :success
    assert_match "Jane Doe", response.body
    assert_no_match "John Smith", response.body
  end

  test "should get index with search query by email" do
    sign_in_as(users(:one))
    get admin_booking_requests_url(q: "john@example.com")
    assert_response :success
    assert_match "John Smith", response.body
    assert_no_match "Jane Doe", response.body
  end

  test "should get index with status filter and search combined" do
    # Jane is 'new', John is 'confirmed'
    sign_in_as(users(:one))
    get admin_booking_requests_url(status: "confirmed", q: "John")
    assert_response :success
    assert_match "John Smith", response.body
    
    sign_in_as(users(:one))
    sign_in_as(users(:one))
    get admin_booking_requests_url(status: "new", q: "John")
    assert_response :success
    assert_no_match "John Smith", response.body
    assert_no_match "Jane Doe", response.body
  end

  test "should show booking request" do
    sign_in_as(users(:one))
    get admin_booking_request_url(@booking_request)
    assert_response :success
  end

  test "should update booking request status" do
    sign_in_as(users(:one))
    patch admin_booking_request_url(@booking_request), params: {
      booking_request: { status: "contacted" }
    }
    assert_redirected_to admin_booking_request_url(@booking_request, locale: nil)
    @booking_request.reload
    assert_equal "contacted", @booking_request.status
  end

  test "should not update to invalid status" do
    sign_in_as(users(:one))
    patch admin_booking_request_url(@booking_request), params: {
      booking_request: { status: "invalid_status" }
    }
    assert_response :unprocessable_entity
    @booking_request.reload
    assert_not_equal "invalid_status", @booking_request.status
  end
end
