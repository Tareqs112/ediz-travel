require "test_helper"

class TourTest < ActiveSupport::TestCase
  test "should have an image attachment" do
    tour = Tour.new
    assert tour.respond_to?(:image)
  end

  test "can belong to a destination" do
    dest = Destination.create!(name: "Trabzon", slug: "trabzon-123")
    tour = Tour.new(
      title: "City Tour",
      description: "A tour",
      slug: "city-tour-123",
      duration: "1 day",
      tour_type: "Private",
      destination: dest
    )
    assert tour.valid?
    assert_equal dest, tour.destination
  end

  test "should handle optional detail fields" do
    tour = tours(:one)
    tour.highlights = ["Highlight 1", "Highlight 2"]
    tour.meeting_point = "Central Hotel"
    tour.cancellation_policy = "24 hours notice"
    
    assert tour.save
    assert_equal ["Highlight 1", "Highlight 2"], tour.highlights
    assert_equal "Central Hotel", tour.meeting_point
    assert_equal "24 hours notice", tour.cancellation_policy
  end

  test "cannot delete tour if it has a booking request that was converted to a booking" do
    tour = tours(:one)
    request = BookingRequest.create!(tour: tour, customer_name: "Test", email: "test@example.com", travel_date: Date.today, travelers_count: 2, status: "new")
    
    # Tour can be deleted if request is not converted
    assert tour.destroy
    assert_equal 0, BookingRequest.where(id: request.id).count
    
    # Recreate
    tour = Tour.create!(title: "Test Tour", description: "Desc", slug: "test-tour")
    request = BookingRequest.create!(tour: tour, customer_name: "Test", email: "test@example.com", travel_date: Date.today, travelers_count: 2, status: "new")
    customer = Customer.create!(name: "Test Customer")
    Booking.create!(booking_request: request, customer: customer, source: "website", status: "confirmed")

    # Deletion should be blocked
    assert_not tour.destroy
    assert_equal 1, BookingRequest.where(id: request.id).count
    assert_equal 1, Tour.where(id: tour.id).count
  end
end
