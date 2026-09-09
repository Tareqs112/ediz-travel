require "test_helper"

class TripInquiryTest < ActiveSupport::TestCase
  setup do
    @valid_params = {
      customer_name: "Test User",
      email: "test@example.com",
      travel_date: Date.tomorrow,
      travelers_count: 2
    }
  end

  test "should be valid with valid attributes" do
    inquiry = TripInquiry.new(@valid_params)
    assert inquiry.valid?
  end

  test "should require customer_name" do
    inquiry = TripInquiry.new(@valid_params.merge(customer_name: nil))
    assert_not inquiry.valid?
  end

  test "should require email" do
    inquiry = TripInquiry.new(@valid_params.merge(email: nil))
    assert_not inquiry.valid?
  end

  test "should require travel_date" do
    inquiry = TripInquiry.new(@valid_params.merge(travel_date: nil))
    assert_not inquiry.valid?
  end

  test "travelers_count must be greater than 0" do
    inquiry = TripInquiry.new(@valid_params.merge(travelers_count: 0))
    assert_not inquiry.valid?
  end

  test "duration_days must be greater than 0 if present" do
    inquiry = TripInquiry.new(@valid_params.merge(duration_days: 0))
    assert_not inquiry.valid?
    
    inquiry.duration_days = 5
    assert inquiry.valid?
  end

  test "should have default status of new" do
    inquiry = TripInquiry.new(@valid_params)
    assert_equal "new", inquiry.status
  end

  test "should validate status inclusion" do
    inquiry = TripInquiry.new(@valid_params)
    
    %w[new contacted quoted confirmed completed cancelled].each do |status|
      inquiry.status = status
      assert inquiry.valid?
    end

    inquiry.status = "invalid"
    assert_not inquiry.valid?
  end
end
