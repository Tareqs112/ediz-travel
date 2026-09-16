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

  test "should display Quick Booking shortcut on index" do
    get admin_bookings_url
    assert_response :success
    assert_select "a", text: /⚡ Quick Booking/
    assert_select "a[href*='quick_bookings']"
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

  test "should display external badge for external drivers on show page" do
    driver = Driver.create!(name: "External Driver", phone: "123", is_external: true)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "assigned", driver: driver)

    get admin_booking_url(@booking)
    assert_response :success
    assert_select "span", text: /Ext/
  end

  test "should not display external badge for internal drivers on show page" do
    driver = Driver.create!(name: "Internal Driver", phone: "123", is_external: false)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "assigned", driver: driver)

    get admin_booking_url(@booking)
    assert_response :success
    assert_select "span", text: /Ext/, count: 0
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

  # ── MARGIN COLOR TESTS ────────────────────────────────────────────────────

  test "negative margin renders with red styling" do
    @booking.update!(total_price: 200.0)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "pending", estimated_cost: 500.0)

    get admin_booking_url(@booking)
    assert_response :success
    # number_to_currency with format "%u %n" renders negative as "-USD 300.00"
    # We assert that the specific exact class string contains the negative value
    assert_match /class="font-bold text-red-600">\s*-USD 300\.00/, response.body
    # Confirm the green class is NOT used for the margin when it is negative
    assert_no_match /class="font-bold text-brand-green-700">\s*-USD 300\.00/, response.body
  end

  test "positive margin retains green styling" do
    @booking.update!(total_price: 1000.0)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "pending", estimated_cost: 300.0)

    get admin_booking_url(@booking)
    assert_response :success
    # Confirm green class is present and red is absent for the margin element
    assert_select "span.font-bold.text-brand-green-700", text: /700/
    assert_select "span.font-bold.text-red-600", text: /700/, count: 0
  end

  test "zero margin retains green styling" do
    @booking.update!(total_price: 300.0)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "pending", estimated_cost: 300.0)

    get admin_booking_url(@booking)
    assert_response :success
    assert_select "span.font-bold.text-brand-green-700"
    assert_select "span.font-bold.text-red-600", text: /Approx/, count: 0
  end

  # ── ASSIGNMENT SUMMARY TESTS ──────────────────────────────────────────────

  test "cancelled service without driver does NOT increase missing-driver count" do
    # Active service — fully assigned
    driver = Driver.create!(name: "Test Driver", phone: "123")
    vehicle = Vehicle.create!(name: "Test Van", plate_number: "61X01")
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "assigned", driver: driver, vehicle: vehicle)
    # Cancelled service with no driver — must be excluded from the count
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "cancelled")

    get admin_booking_url(@booking)
    assert_response :success
    # "Active services" should be 1 (only the assigned one)
    assert_select "span.font-bold", text: "0", count: 2 # missing driver=0, missing vehicle=0
    assert_select "span.font-bold", text: "1" # active services = 1
  end

  test "cancelled service without vehicle does NOT increase missing-vehicle count" do
    driver = Driver.create!(name: "Test Driver", phone: "123")
    vehicle = Vehicle.create!(name: "Test Van", plate_number: "61X02")
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "assigned", driver: driver, vehicle: vehicle)
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "cancelled")

    get admin_booking_url(@booking)
    assert_response :success
    # missing vehicle must be 0 — the cancelled unassigned service is excluded
    assert_select "div.flex.justify-between", text: /Missing vehicle.*0/
  end

  test "active service without driver still counts in missing-driver" do
    vehicle = Vehicle.create!(name: "Test Van", plate_number: "61X03")
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "pending", vehicle: vehicle)

    get admin_booking_url(@booking)
    assert_response :success
    assert_select "div.flex.justify-between", text: /Missing driver.*1/
  end

  test "active service without vehicle still counts in missing-vehicle" do
    driver = Driver.create!(name: "Test Driver", phone: "123")
    TripService.create!(booking: @booking, service_type: "tour", date: Date.today, status: "pending", driver: driver)

    get admin_booking_url(@booking)
    assert_response :success
    assert_select "div.flex.justify-between", text: /Missing vehicle.*1/
  end

  test "booking show displays Services label not Legs" do
    get admin_booking_url(@booking)
    assert_response :success
    assert_select "div", text: /Services/
    assert_no_match(/\bLegs\b/, response.body)
  end
end
