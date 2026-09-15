require "test_helper"

class QuickBookingFormTest < ActiveSupport::TestCase
  setup do
    @valid_params = {
      customer_name: "John Quick",
      customer_phone: "+90 555 123 4567",
      customer_email: "john@example.com",
      source: "whatsapp",
      status: "confirmed",
      start_date: "2026-10-10",
      end_date: "2026-10-15",
      total_price: "150.00",
      currency: "USD",
      service_type: "airport_transfer",
      service_date: "2026-10-10",
      start_time: "14:00",
      pickup_location: "TZX Airport",
      dropoff_location: "City Hotel"
    }
  end

  test "valid form creates customer, booking, and trip service" do
    form = QuickBookingForm.new(@valid_params)
    
    assert form.valid?
    
    assert_difference -> { Customer.count } => 1,
                      -> { Booking.count } => 1,
                      -> { TripService.count } => 1 do
      assert form.save
    end
    
    customer = form.customer
    assert_equal "John Quick", customer.name
    assert_equal "+90 555 123 4567", customer.phone
    
    booking = form.booking
    assert_equal customer, booking.customer
    assert_equal "whatsapp", booking.source
    assert_equal 150.00, booking.total_price
    assert_equal "USD", booking.currency
    
    trip_service = form.trip_service
    assert_equal booking, trip_service.booking
    assert_equal "airport_transfer", trip_service.service_type
    assert_equal "TZX Airport", trip_service.pickup_location
  end

  test "reuses existing customer if normalized phone matches" do
    # 905551234567 is the normalized version of +90 555 123 4567
    existing_customer = Customer.create!(name: "Old Name", phone: "90-555-123-4567", email: "old@test.com")
    
    form = QuickBookingForm.new(@valid_params)
    
    assert_difference -> { Customer.count } => 0,
                      -> { Booking.count } => 1 do
      assert form.save
    end
    
    assert_equal existing_customer.id, form.customer.id
    # We do not overwrite name intentionally per requirements
    assert_equal "Old Name", form.customer.name
  end

  test "reuses existing customer if Turkish phone formats differ (05xx vs 905xx)" do
    existing_customer = Customer.create!(name: "Turkish User", phone: "05540171890", email: "tr@test.com")
    
    # Provide international format in the form
    params = @valid_params.merge(customer_phone: "+90 554 017 18 90")
    form = QuickBookingForm.new(params)
    
    assert_difference -> { Customer.count } => 0 do
      assert form.save
    end
    
    assert_equal existing_customer.id, form.customer.id
  end

  test "rolls back everything if trip service is invalid" do
    # Missing service_date which is required by TripService
    invalid_params = @valid_params.merge(service_date: nil)
    form = QuickBookingForm.new(invalid_params)
    
    assert_no_difference -> { Customer.count } do
      assert_no_difference -> { Booking.count } do
        assert_no_difference -> { TripService.count } do
          assert_not form.save
        end
      end
    end
    
    assert form.errors.any?
  end

  test "validates required fields on form object itself" do
    form = QuickBookingForm.new
    assert_not form.valid?
    
    assert_includes form.errors[:customer_name], "can't be blank"
    assert_includes form.errors[:customer_phone], "can't be blank"
    assert_includes form.errors[:service_date], "can't be blank"
  end
end
