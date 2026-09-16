require "test_helper"

class Admin::TripServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    @customer = Customer.create!(name: "Test Customer")
    @booking = Booking.create!(customer: @customer, source: "website", status: "draft", start_date: Date.today)
    @driver = Driver.create!(name: "Ali", phone: "+905551234567")
    @vehicle = Vehicle.create!(name: "Mercedes Vito", plate_number: "61 ABC 01")

    @trip_service = TripService.create!(
      booking: @booking,
      service_type: "airport_transfer",
      date: Date.today,
      status: "pending",
      pickup_location: "Trabzon Airport"
    )
  end

  # ---- CRUD ----

  test "should get new" do
    @driver.update!(is_external: true)
    get new_admin_booking_trip_service_url(@booking)
    assert_response :success
    assert_select "option", text: /#{@driver.name} \(External\)/
  end

  test "should create trip service" do
    assert_difference("TripService.count") do
      post admin_booking_trip_services_url(@booking), params: {
        trip_service: {
          service_type: "tour",
          date: Date.tomorrow,
          status: "pending",
          pickup_location: "Hotel"
        }
      }
    end
    assert_redirected_to admin_booking_url(@booking, locale: nil)
    follow_redirect!
    assert_match "Service was successfully added", response.body
  end

  test "should get edit" do
    get edit_admin_booking_trip_service_url(@booking, @trip_service)
    assert_response :success
  end

  test "should update trip service" do
    patch admin_booking_trip_service_url(@booking, @trip_service), params: {
      trip_service: { pickup_location: "New Hotel", status: "completed", estimated_cost: "150.00" }
    }
    assert_redirected_to admin_booking_url(@booking, locale: nil)
    @trip_service.reload
    assert_equal "New Hotel", @trip_service.pickup_location
    assert_equal "completed", @trip_service.status
    assert_equal 150.0, @trip_service.estimated_cost
  end

  test "should destroy trip service" do
    assert_difference("TripService.count", -1) do
      delete admin_booking_trip_service_url(@booking, @trip_service)
    end
    assert_redirected_to admin_booking_url(@booking, locale: nil)
  end

  # ---- Driver/Vehicle Assignment ----

  test "should assign driver" do
    patch admin_booking_trip_service_url(@booking, @trip_service), params: {
      trip_service: { driver_id: @driver.id }
    }
    @trip_service.reload
    assert_equal @driver.id, @trip_service.driver_id
  end

  test "should assign vehicle" do
    patch admin_booking_trip_service_url(@booking, @trip_service), params: {
      trip_service: { vehicle_id: @vehicle.id }
    }
    @trip_service.reload
    assert_equal @vehicle.id, @trip_service.vehicle_id
  end

  test "should clear driver assignment" do
    @trip_service.update!(driver: @driver)
    patch admin_booking_trip_service_url(@booking, @trip_service), params: {
      trip_service: { driver_id: "" }
    }
    @trip_service.reload
    assert_nil @trip_service.driver_id
  end

  test "should clear vehicle assignment" do
    @trip_service.update!(vehicle: @vehicle)
    patch admin_booking_trip_service_url(@booking, @trip_service), params: {
      trip_service: { vehicle_id: "" }
    }
    @trip_service.reload
    assert_nil @trip_service.vehicle_id
  end

  # ---- Status Changes ----

  test "should change service status" do
    patch admin_booking_trip_service_url(@booking, @trip_service), params: {
      trip_service: { status: "completed" }
    }
    @trip_service.reload
    assert_equal "completed", @trip_service.status
  end

  # ---- Validation ----

  test "should reject invalid service type" do
    post admin_booking_trip_services_url(@booking), params: {
      trip_service: {
        service_type: "nonexistent_type",
        date: Date.today,
        status: "pending"
      }
    }
    assert_response :unprocessable_entity
  end

  test "should reject missing date" do
    post admin_booking_trip_services_url(@booking), params: {
      trip_service: {
        service_type: "tour",
        date: "",
        status: "pending"
      }
    }
    assert_response :unprocessable_entity
  end

  # ---- Cross-Booking Security ----

  test "should not access trip service from another booking" do
    other_customer = Customer.create!(name: "Other Customer")
    other_booking = Booking.create!(customer: other_customer, source: "phone", status: "draft")
    other_service = TripService.create!(booking: other_booking, service_type: "tour", date: Date.today, status: "pending")

    get edit_admin_booking_trip_service_url(@booking, other_service)
    assert_response :not_found
  end

  test "should not update trip service from another booking" do
    other_customer = Customer.create!(name: "Other Customer 2")
    other_booking = Booking.create!(customer: other_customer, source: "phone", status: "draft")
    other_service = TripService.create!(booking: other_booking, service_type: "tour", date: Date.today, status: "pending")

    patch admin_booking_trip_service_url(@booking, other_service), params: {
      trip_service: { status: "cancelled" }
    }
    assert_response :not_found
    other_service.reload
    assert_equal "pending", other_service.status
  end

  # ---- Authorization ----

  test "should redirect unauthenticated user" do
    delete session_url
    get new_admin_booking_trip_service_url(@booking)
    assert_redirected_to new_session_url
  end
end
