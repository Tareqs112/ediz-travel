require "test_helper"

class BookingRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tour = tours(:one)
    @valid_params = {
      booking_request: {
        customer_name: "Test User",
        email: "test@example.com",
        travel_date: Date.tomorrow.to_s,
        travelers_count: 2,
        preferred_language: "English",
        notes: "Some notes"
      }
    }
  end

  test "should get new" do
    get new_tour_booking_request_url(@tour)
    assert_response :success
  end

  test "should create booking_request" do
    assert_difference("BookingRequest.count") do
      post tour_booking_requests_url(@tour), params: @valid_params
    end

    booking_request = BookingRequest.last
    assert_redirected_to tour_booking_request_url(@tour, booking_request)
    assert_equal @tour, booking_request.tour
    assert_equal "new", booking_request.status
  end

  test "should not create booking_request with invalid params" do
    assert_no_difference("BookingRequest.count") do
      post tour_booking_requests_url(@tour), params: {
        booking_request: {
          customer_name: "", # invalid
          email: "test@example.com",
          travel_date: Date.tomorrow.to_s,
          travelers_count: 2
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not allow customer to set status" do
    assert_difference("BookingRequest.count") do
      post tour_booking_requests_url(@tour), params: {
        booking_request: {
          customer_name: "Test User",
          email: "test@example.com",
          travel_date: Date.tomorrow.to_s,
          travelers_count: 2,
          status: "confirmed" # malicious param
        }
      }
    end

    booking_request = BookingRequest.last
    assert_equal "new", booking_request.status, "Status should remain new despite params"
  end

  test "should show booking_request" do
    booking_request = booking_requests(:one)
    get tour_booking_request_url(@tour, booking_request)
    assert_response :success
  end

  test "should return 404 when requesting booking for inactive tour" do
    inactive_tour = tours(:two)
    get new_tour_booking_request_url(inactive_tour)
    assert_response :not_found
  end
end
