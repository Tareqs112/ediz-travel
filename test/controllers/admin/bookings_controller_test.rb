require "test_helper"

class Admin::BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    @customer = Customer.create!(name: "Jane Smith")
    @booking = Booking.create!(customer: @customer, source: "walk_in", status: "draft")
  end

  test "should get index" do
    get admin_bookings_url
    assert_response :success
  end

  test "should render trip services summary on index" do
    # 0 services
    get admin_bookings_url
    assert_select "td", text: /0 services/

    # 1 unassigned service
    service1 = TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "pending")
    get admin_bookings_url
    assert_select "td", text: /1 service/
    assert_select "td", text: /1 needs assignment/

    # 2 services, 1 unassigned
    driver = Driver.create!(name: "Test Driver", phone: "123")
    vehicle = Vehicle.create!(name: "Test Vehicle", plate_number: "ABC")
    service2 = TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "assigned", driver: driver, vehicle: vehicle)
    get admin_bookings_url
    assert_select "td", text: /2 services/
    assert_select "td", text: /1 needs assignment/

    # 2 services, fully assigned
    service1.update!(driver: driver, vehicle: vehicle)
    get admin_bookings_url
    assert_select "td", text: /2 services/
    assert_select "td", text: /needs assignment/, count: 0
  end

  test "should get new" do
    get new_admin_booking_url
    assert_response :success
  end

  test "should create booking" do
    assert_difference("Booking.count") do
      post admin_bookings_url, params: { booking: { customer_id: @customer.id, source: "phone", status: "confirmed" } }
    end
    assert_redirected_to admin_booking_url(Booking.last, locale: nil)
  end

  test "should get show" do
    get admin_booking_url(@booking)
    assert_response :success
  end

  test "should display margin and estimated cost on show page" do
    @booking.update!(total_price: 1000.0)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "pending", estimated_cost: 300.0)

    get admin_booking_url(@booking)
    assert_response :success

    assert_select "span", text: /Customer Price:/
    assert_select "span", text: /1,000/

    assert_select "span", text: /Estimated Cost:/
    assert_select "span", text: /300/

    assert_select "span", text: /Approx. Margin:/
    assert_select "span", text: /700/
  end

  test "should get edit" do
    get edit_admin_booking_url(@booking)
    assert_response :success
  end

  test "should update booking" do
    patch admin_booking_url(@booking), params: { booking: { status: "active" } }
    assert_redirected_to admin_booking_url(@booking, locale: nil)
    @booking.reload
    assert_equal "active", @booking.status
  end

  test "should destroy booking" do
    assert_difference("Booking.count", -1) do
      delete admin_booking_url(@booking)
    end
    assert_redirected_to admin_bookings_url(locale: nil)
  end

  test "should not destroy booking with trip services" do
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "pending")

    assert_no_difference("Booking.count") do
      delete admin_booking_url(@booking)
    end

    assert_redirected_to admin_booking_url(@booking, locale: nil)
    follow_redirect!
    assert_match /Cannot delete record because dependent trip services exist/, response.body
  end

  test "should redirect unauthenticated user" do
    delete session_url
    get admin_bookings_url
    assert_redirected_to new_session_url
  end
end
