require "test_helper"

class Admin::VehicleOperationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    @customer = Customer.create!(name: "Jane Smith")
    @booking = Booking.create!(customer: @customer, source: "website", status: "confirmed")
    
    @driver = Driver.create!(name: "Ahmed", phone: "123")
    @vehicle = Vehicle.create!(name: "Vito", plate_number: "61 A 1")
    @other_vehicle = Vehicle.create!(name: "Sprinter", plate_number: "61 B 2")
    
    @today = Date.today
  end

  test "should get vehicle operations for today" do
    TripService.create!(booking: @booking, service_type: "tour", date: @today, status: "assigned", vehicle: @vehicle)
    
    get operations_admin_vehicle_url(@vehicle)
    assert_response :success
    assert_select "div.text-sm.font-bold.text-gray-900.mb-1", text: /Tour/
  end

  test "should not show services for other vehicles" do
    TripService.create!(booking: @booking, service_type: "airport_transfer", date: @today, status: "assigned", vehicle: @other_vehicle)
    
    get operations_admin_vehicle_url(@vehicle)
    assert_response :success
    assert_select "h3", text: /No Services/
  end

  test "should filter by date" do
    TripService.create!(booking: @booking, service_type: "tour", date: @today.tomorrow, status: "assigned", vehicle: @vehicle)
    
    get operations_admin_vehicle_url(@vehicle, date: @today.to_s)
    assert_select "h3", text: /No Services/

    get operations_admin_vehicle_url(@vehicle, date: @today.tomorrow.to_s)
    assert_select "div.text-sm.font-bold.text-gray-900.mb-1", text: /Tour/
  end

  test "should handle invalid date gracefully" do
    get operations_admin_vehicle_url(@vehicle, date: "invalid-date")
    assert_response :success
    assert_select "h2", text: /#{@today.strftime("%A, %d %b %Y")}/
  end

  test "should render customer and booking info correctly" do
    TripService.create!(booking: @booking, service_type: "tour", date: @today, status: "assigned", vehicle: @vehicle)
    
    get operations_admin_vehicle_url(@vehicle)
    assert_response :success
    assert_select "a", text: @customer.name
    assert_select "a", text: "Booking ##{@booking.id}"
  end
end
