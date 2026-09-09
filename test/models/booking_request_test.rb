require "test_helper"

class BookingRequestTest < ActiveSupport::TestCase
  setup do
    @tour = tours(:one)
    @valid_params = {
      customer_name: "Test User",
      email: "test@example.com",
      travel_date: Date.tomorrow,
      travelers_count: 2,
      tour: @tour
    }
  end

  test "should be valid with valid attributes" do
    booking = BookingRequest.new(@valid_params)
    assert booking.valid?
  end

  test "should require customer_name" do
    booking = BookingRequest.new(@valid_params.merge(customer_name: nil))
    assert_not booking.valid?
    assert_includes booking.errors[:customer_name], "can't be blank"
  end

  test "should require email" do
    booking = BookingRequest.new(@valid_params.merge(email: nil))
    assert_not booking.valid?
    assert_includes booking.errors[:email], "can't be blank"
  end

  test "should require travel_date" do
    booking = BookingRequest.new(@valid_params.merge(travel_date: nil))
    assert_not booking.valid?
    assert_includes booking.errors[:travel_date], "can't be blank"
  end

  test "travelers_count must be greater than 0" do
    booking = BookingRequest.new(@valid_params.merge(travelers_count: 0))
    assert_not booking.valid?
    assert_includes booking.errors[:travelers_count], "must be greater than 0"

    booking.travelers_count = -1
    assert_not booking.valid?
  end

  test "should have default status of new" do
    booking = BookingRequest.new(@valid_params)
    assert_equal "new", booking.status
  end

  test "should validate status inclusion" do
    booking = BookingRequest.new(@valid_params)
    
    # Valid statuses
    %w[new contacted quoted confirmed completed cancelled].each do |status|
      booking.status = status
      assert booking.valid?, "#{status} should be valid"
    end

    # Invalid status
    booking.status = "invalid_status"
    assert_not booking.valid?
    assert_includes booking.errors[:status], "is not included in the list"
  end

  test "should belong to a tour" do
    booking = BookingRequest.new(@valid_params)
    assert_equal @tour, booking.tour
  end
end
