require "test_helper"

class Admin::DriverOperationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    @customer = Customer.create!(name: "Jane Smith")
    @booking = Booking.create!(customer: @customer, source: "website", status: "confirmed")
    
    @driver = Driver.create!(name: "Ahmed", phone: "123")
    @other_driver = Driver.create!(name: "Mehmet", phone: "456")
    @vehicle = Vehicle.create!(name: "Vito", plate_number: "61 A 1")
    
    @today = Date.today
  end

  test "should get driver operations for today" do
    TripService.create!(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver)
    
    get operations_admin_driver_url(@driver)
    assert_response :success
    assert_select "div.text-sm.font-bold.text-gray-900.mb-1", text: /Tour/
  end

  test "should not show services for other drivers" do
    TripService.create!(booking: @booking, service_type: "airport_transfer", date: @today, status: "assigned", driver: @other_driver)
    
    get operations_admin_driver_url(@driver)
    assert_response :success
    assert_select "h3", text: /No Services/
  end

  test "should filter by date" do
    TripService.create!(booking: @booking, service_type: "tour", date: @today.tomorrow, status: "assigned", driver: @driver)
    
    get operations_admin_driver_url(@driver, date: @today.to_s)
    assert_select "h3", text: /No Services/

    get operations_admin_driver_url(@driver, date: @today.tomorrow.to_s)
    assert_select "div.text-sm.font-bold.text-gray-900.mb-1", text: /Tour/
  end

  test "should handle invalid date gracefully" do
    get operations_admin_driver_url(@driver, date: "invalid-date")
    assert_response :success
    # Falls back to today
    assert_select "h2", text: /#{@today.strftime("%A, %d %b %Y")}/
  end
  
  test "should render customer and booking info correctly" do
    TripService.create!(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver)
    
    get operations_admin_driver_url(@driver)
    assert_response :success
    assert_select "a", text: @customer.name
    assert_select "a", text: "Booking ##{@booking.id}"
  end
end
