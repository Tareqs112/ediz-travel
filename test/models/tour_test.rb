require "test_helper"

class TourTest < ActiveSupport::TestCase
  test "should have an image attachment" do
    tour = Tour.new
    assert tour.respond_to?(:image)
  end
end
