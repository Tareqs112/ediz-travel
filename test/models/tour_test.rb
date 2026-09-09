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
end
