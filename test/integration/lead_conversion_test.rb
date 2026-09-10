require "test_helper"

class LeadConversionTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    @tour = tours(:one)
    @booking_request = BookingRequest.create!(
      tour: @tour,
      customer_name: "Test Customer",
      email: "test@example.com",
      phone: "123-456",
      travel_date: Date.tomorrow,
      travelers_count: 2,
      status: "new"
    )
  end

  test "converts booking request to booking and preserves lead" do
    assert_difference("Customer.count", 1) do
      assert_difference("Booking.count", 1) do
        post convert_to_booking_admin_booking_request_url(@booking_request)
      end
    end

    booking = Booking.last
    assert_redirected_to admin_booking_url(booking)

    assert_equal "Test Customer", booking.customer.name
    assert_equal "test@example.com", booking.customer.email
    assert_equal @booking_request.id, booking.booking_request_id
    assert_equal "website", booking.source
    assert_equal "draft", booking.status

    # Lead is untouched
    @booking_request.reload
    assert_equal "new", @booking_request.status
  end

  test "prevents duplicate conversion" do
    post convert_to_booking_admin_booking_request_url(@booking_request)
    booking = Booking.last

    assert_no_difference("Booking.count") do
      post convert_to_booking_admin_booking_request_url(@booking_request)
    end

    assert_redirected_to admin_booking_url(booking)
  end

  test "matches existing customer by email" do
    existing_customer = Customer.create!(name: "Test Customer", email: "test@example.com")

    assert_no_difference("Customer.count") do
      assert_difference("Booking.count", 1) do
        post convert_to_booking_admin_booking_request_url(@booking_request)
      end
    end

    assert_equal existing_customer.id, Booking.last.customer_id
  end

  test "does not match if multiple customers have the same email" do
    Customer.create!(name: "Test Customer 1", email: "test@example.com")
    Customer.create!(name: "Test Customer 2", email: "test@example.com")

    assert_difference("Customer.count", 1) do
      assert_difference("Booking.count", 1) do
        post convert_to_booking_admin_booking_request_url(@booking_request)
      end
    end
  end


end
