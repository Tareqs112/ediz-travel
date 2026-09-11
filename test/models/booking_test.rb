require "test_helper"

class BookingTest < ActiveSupport::TestCase
  setup do
    @customer = Customer.create!(name: "Test Customer")
  end

  test "should save valid booking" do
    booking = Booking.new(customer: @customer, source: "website", status: "draft")
    assert booking.save
  end

  test "validates source" do
    booking = Booking.new(customer: @customer, source: "invalid_source", status: "draft")
    assert_not booking.save
  end

  test "validates status" do
    booking = Booking.new(customer: @customer, source: "website", status: "invalid_status")
    assert_not booking.save
  end

  test "prevents duplicate booking for same booking_request" do
    tour = tours(:one)
    request = BookingRequest.create!(tour: tour, customer_name: "John", email: "test@example.com", travel_date: Date.tomorrow, travelers_count: 2, status: "new")

    booking1 = Booking.create!(customer: @customer, booking_request: request, source: "website", status: "draft")
    booking2 = Booking.new(customer: @customer, booking_request: request, source: "phone", status: "confirmed")

    assert_not booking2.save
  end

  test "should delete booking without trip services" do
    booking = Booking.create!(customer: @customer, source: "website", status: "draft")
    assert booking.destroy
  end

  test "should not delete booking with trip services" do
    booking = Booking.create!(customer: @customer, source: "website", status: "draft")
    TripService.create!(booking: booking, service_type: "tour", date: Date.today, status: "pending")
    
    assert_not booking.destroy
    assert_includes booking.errors[:base], "Cannot delete record because dependent trip services exist"
    assert_equal 1, TripService.count
  end
end
