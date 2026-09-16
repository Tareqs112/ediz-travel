require "test_helper"

class BookingMarginTest < ActiveSupport::TestCase
  setup do
    @customer = Customer.create!(name: "Margin Test")
    @booking = Booking.create!(customer: @customer, source: "website", status: "confirmed", total_price: 850.00, currency: "USD")
  end

  test "calculates estimated cost and margin from multiple services" do
    TripService.create!(booking: @booking, service_type: "airport_transfer", date: Date.today, estimated_cost: 40.0)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, estimated_cost: 100.0)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, estimated_cost: 120.0)
    TripService.create!(booking: @booking, service_type: "airport_transfer", date: Date.today, estimated_cost: 40.0)

    assert_equal 300.0, @booking.total_estimated_cost
    assert_equal 550.0, @booking.approximate_margin
  end

  test "ignores nil estimated costs safely and marks incomplete" do
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, estimated_cost: 100.0)
    TripService.create!(booking: @booking, service_type: "airport_transfer", date: Date.today, estimated_cost: nil)

    assert_equal 100.0, @booking.total_estimated_cost
    assert_equal 750.0, @booking.approximate_margin
    assert @booking.has_incomplete_costs?
  end

  test "returns nil if all costs are missing, not 0" do
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, estimated_cost: nil)
    assert_nil @booking.total_estimated_cost
    assert_nil @booking.approximate_margin
    assert_not @booking.has_incomplete_costs?
  end

  test "returns 0 if explicitly entered as 0" do
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, estimated_cost: 0.0)
    assert_equal 0.0, @booking.total_estimated_cost
    assert_equal 850.0, @booking.approximate_margin
    assert_not @booking.has_incomplete_costs?
  end

  test "ignores cancelled services in cost calculation" do
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, estimated_cost: 100.0)
    TripService.create!(booking: @booking, service_type: "airport_transfer", date: Date.today, estimated_cost: 40.0, status: "cancelled")

    assert_equal 100.0, @booking.total_estimated_cost
    assert_equal 750.0, @booking.approximate_margin
  end

  test "handles nil booking total price gracefully" do
    @booking.update!(total_price: nil)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, estimated_cost: 100.0)

    assert_equal 100.0, @booking.total_estimated_cost
    assert_nil @booking.approximate_margin
  end
end
