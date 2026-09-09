require "test_helper"

class TripInquiriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip_inquiry = trip_inquiries(:one)
  end

  test "should get new" do
    get plan_your_trip_url
    assert_response :success
  end

  test "should create general trip_inquiry" do
    assert_difference("TripInquiry.count") do
      post trip_inquiries_url, params: { trip_inquiry: { customer_name: "Test", email: "test@example.com", travel_date: Date.today, travelers_count: 2, duration_days: 5, inquiry_type: "general" } }
    end
    assert_redirected_to trip_inquiry_url(TripInquiry.last)
  end
  
  test "should create airport_transfer trip_inquiry" do
    assert_difference("TripInquiry.count") do
      post trip_inquiries_url, params: { 
        trip_inquiry: { 
          customer_name: "Test", 
          email: "test@example.com", 
          travel_date: Date.today, 
          travelers_count: 2, 
          inquiry_type: "airport_transfer",
          pickup_time: "14:00",
          pickup_location: "TZX Airport",
          dropoff_location: "Zorlu Grand Hotel",
          flight_details: "TK2831"
        } 
      }
    end
    assert_redirected_to trip_inquiry_url(TripInquiry.last)
  end
  
  test "should fail to create airport_transfer if missing required pickup_location" do
    assert_no_difference("TripInquiry.count") do
      post trip_inquiries_url, params: { 
        trip_inquiry: { 
          customer_name: "Test", 
          email: "test@example.com", 
          travel_date: Date.today, 
          travelers_count: 2, 
          inquiry_type: "airport_transfer",
          pickup_time: "14:00",
          dropoff_location: "Zorlu Grand Hotel"
        } 
      }
    end
    assert_response :unprocessable_entity
  end

  test "should show trip_inquiry" do
    get trip_inquiry_url(@trip_inquiry)
    assert_response :success
  end
end
