require "test_helper"

class Admin::OperationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    @customer = Customer.create!(name: "Jane Smith")
    @booking = Booking.create!(customer: @customer, source: "website", status: "confirmed")
    
    @driver1 = Driver.create!(name: "Ahmed", phone: "123")
    @driver2 = Driver.create!(name: "Mehmet", phone: "456")
    
    @vehicle1 = Vehicle.create!(name: "Vito 1", plate_number: "61 A 1")
    @vehicle2 = Vehicle.create!(name: "Vito 2", plate_number: "61 B 2")
    
    @today = Date.today
  end

  test "should get operations index for today" do
    get admin_operations_url
    assert_response :success
    assert_select "h1", text: /Daily Operations/
  end

  test "should display external badge for external drivers" do
    @driver1.update!(is_external: true)
    TripService.create!(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1)
    get admin_operations_url(date: @today.to_s)
    assert_response :success
    assert_select "span", text: /Ext/
  end

  test "should not display external badge for internal drivers" do
    @driver1.update!(is_external: false)
    TripService.create!(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1)
    get admin_operations_url(date: @today.to_s)
    assert_response :success
    assert_select "span", text: /Ext/, count: 0
  end

  test "should display summary metrics" do
    # 1 assigned
    s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, vehicle: @vehicle1); s.save(validate: false)
    
    # 1 needs driver
    s = TripService.new(booking: @booking, service_type: "airport_transfer", date: @today, status: "pending", vehicle: @vehicle2); s.save(validate: false)

    # 1 needs vehicle
    s = TripService.new(booking: @booking, service_type: "private_transfer", date: @today, status: "pending", driver: @driver2); s.save(validate: false)

    # 1 completely unassigned and in progress (weird state but validates logic)
    s = TripService.new(booking: @booking, service_type: "chauffeured_car", date: @today, status: "in_progress"); s.save(validate: false)

    # 1 cancelled
    s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "cancelled"); s.save(validate: false)

    get admin_operations_url
    assert_response :success
    
    # Total includes cancelled, but logic in view uses @total which is 5
    # Wait, my logic: active = reject cancelled. Total = all.
    assert_select "div.text-xl", text: "5" # total
    assert_select "div.text-xl", text: "1" # assigned
    assert_select "div.text-xl", text: "2" # needs driver (the one with only vehicle + the completely unassigned)
    assert_select "div.text-xl", text: "2" # needs vehicle (the one with only driver + the completely unassigned)
    assert_select "div.text-xl", text: "1" # in progress
    assert_select "div.text-xl", text: "0" # completed
  end

  test "should detect driver conflicts on overlapping times" do
    # 09:00 - 13:00
    s1 = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, start_time: "09:00", end_time: "13:00").tap { |s| s.save(validate: false) }
    # 12:00 - 15:00 (overlaps)
    s2 = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, start_time: "12:00", end_time: "15:00").tap { |s| s.save(validate: false) }
    
    # No conflict for @driver2
    s3 = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver2, start_time: "09:00", end_time: "13:00").tap { |s| s.save(validate: false) }

    get admin_operations_url
    assert_response :success
    assert_select "h3", text: /Driver Conflict: Ahmed/
    assert_select "h3", text: /Driver Conflict: Mehmet/, count: 0
  end

  test "should not detect conflicts if times have exactly sufficient buffer" do
  s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, start_time: "09:00", end_time: "12:00"); s.save(validate: false)
  s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, start_time: "12:45", end_time: "15:00"); s.save(validate: false)

  get admin_operations_url
  assert_response :success
  assert_select "h3", text: /Driver Conflict/, count: 0
end

test "should detect conflicts if adjacent services lack sufficient buffer" do
  s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, start_time: "09:00", end_time: "12:00"); s.save(validate: false)
  s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, start_time: "12:00", end_time: "15:00"); s.save(validate: false)

  get admin_operations_url
  assert_response :success
  assert_select "h3", text: /Driver Conflict/
end

  test "should not detect conflicts if one service is cancelled" do
    s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, start_time: "09:00", end_time: "13:00"); s.save(validate: false)
    s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "cancelled", driver: @driver1, start_time: "12:00", end_time: "15:00"); s.save(validate: false)

    get admin_operations_url
    assert_response :success
    assert_select "h3", text: /Driver Conflict/, count: 0
  end

  test "should detect vehicle conflicts" do
    s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", vehicle: @vehicle1, start_time: "09:00", end_time: "13:00"); s.save(validate: false)
    s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", vehicle: @vehicle1, start_time: "10:00", end_time: "14:00"); s.save(validate: false)

    get admin_operations_url
    assert_response :success
    assert_select "h3", text: /Vehicle Conflict: Vito 1/
  end

  test "should not detect conflicts if missing times" do
    s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, start_time: "09:00", end_time: nil); s.save(validate: false)
    s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "assigned", driver: @driver1, start_time: "09:00", end_time: "14:00"); s.save(validate: false)

    get admin_operations_url
    assert_response :success
    assert_select "h3", text: /Driver Conflict/, count: 0
  end

  test "should filter by date" do
    s = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "pending"); s.save(validate: false)
    s = TripService.new(booking: @booking, service_type: "tour", date: @today.tomorrow, status: "pending"); s.save(validate: false)

    get admin_operations_url(date: @today.tomorrow.to_s)
    assert_response :success
    assert_select "div.text-xl", text: "1" # Total should be 1, not 2
  end

  test "should handle invalid date gracefully" do
    get admin_operations_url(date: "invalid-date")
    assert_response :success
    assert_select "h1", text: /Daily Operations/
  end

  test "should auto-assign status when driver and vehicle are present" do
    service = TripService.new(booking: @booking, service_type: "tour", date: @today, status: "pending").tap { |s| s.save(validate: false) }
    
    # Still pending if only one is present
    service.update!(driver: @driver1)
    assert_equal "pending", service.status

    # Automatically updates to assigned when both are present
    service.update!(vehicle: @vehicle1)
    assert_equal "assigned", service.status
  end

test "should get availability lookup page" do
  get admin_operations_availability_url(date: @today, start_time: "10:00")
  assert_response :success
  assert_select "h1", text: /Who's Free/
  assert_select "div", text: /#{@driver1.name}/
  assert_select "div", text: /#{@vehicle1.name}/
end

# ─── WINDOW AVAILABILITY TESTS ───────────────────────────────────────────────

test "availability: driver is BUSY when requested window overlaps existing service + buffer" do
  # Existing service: 10:00–12:00. Buffer expands to 09:15–12:45.
  # Requested window: 12:30–14:00 → start (12:30) < buffer_end (12:45) AND end (14:00) > buffer_start (09:15) → BUSY
  TripService.new(booking: @booking, service_type: "tour", date: @today,
                  status: "assigned", driver: @driver1,
                  start_time: "10:00", end_time: "12:00").tap { |s| s.save(validate: false) }

  get admin_operations_availability_url(date: @today, start_time: "12:30", end_time: "14:00")
  assert_response :success
  assert_select "div", text: /Busy/
  assert_select "div", text: /#{@driver1.name}/
end

test "availability: driver is AVAILABLE when requested window is just past buffer" do
  # Existing service: 10:00–12:00. Buffer end = 12:45.
  # Requested window: 12:45–14:00 → start (765) NOT < buffer_end (765) → AVAILABLE (strict <)
  TripService.new(booking: @booking, service_type: "tour", date: @today,
                  status: "assigned", driver: @driver1,
                  start_time: "10:00", end_time: "12:00").tap { |s| s.save(validate: false) }

  get admin_operations_availability_url(date: @today, start_time: "12:45", end_time: "14:00")
  assert_response :success
  assert_select "div", text: /Available/
  assert_no_match(/Busy/, response.body)
end

test "availability: cancelled services do NOT mark driver as busy" do
  TripService.new(booking: @booking, service_type: "tour", date: @today,
                  status: "cancelled", driver: @driver1,
                  start_time: "10:00", end_time: "12:00").tap { |s| s.save(validate: false) }

  get admin_operations_availability_url(date: @today, start_time: "10:30", end_time: "11:30")
  assert_response :success
  # driver1 should appear in the available section, not busy
  assert_no_match(/Busy/, response.body)
end

test "availability: vehicle is BUSY when requested window conflicts" do
  TripService.new(booking: @booking, service_type: "airport_transfer", date: @today,
                  status: "assigned", vehicle: @vehicle1,
                  start_time: "08:00", end_time: "10:00").tap { |s| s.save(validate: false) }

  get admin_operations_availability_url(date: @today, start_time: "10:30", end_time: "12:00")
  assert_response :success
  assert_select "div", text: /#{@vehicle1.name}/
  assert_select "div", text: /Busy/
end

test "availability: vehicle is AVAILABLE when requested window is past buffer" do
  TripService.new(booking: @booking, service_type: "airport_transfer", date: @today,
                  status: "assigned", vehicle: @vehicle1,
                  start_time: "08:00", end_time: "10:00").tap { |s| s.save(validate: false) }

  # Buffer end = 10:45. Request starts at 10:45 → NOT busy (strict inequality)
  get admin_operations_availability_url(date: @today, start_time: "10:45", end_time: "12:00")
  assert_response :success
  assert_no_match(/Busy/, response.body)
end

test "availability: multiple blocking services are all shown for a busy driver" do
  # Two non-overlapping services on the same driver, both in the requested window
  TripService.new(booking: @booking, service_type: "tour", date: @today,
                  status: "assigned", driver: @driver1,
                  start_time: "08:00", end_time: "09:00").tap { |s| s.save(validate: false) }
  TripService.new(booking: @booking, service_type: "airport_transfer", date: @today,
                  status: "assigned", driver: @driver1,
                  start_time: "13:00", end_time: "15:00").tap { |s| s.save(validate: false) }

  # Both should block a window that spans both buffers
  get admin_operations_availability_url(date: @today, start_time: "09:30", end_time: "13:30")
  assert_response :success
  assert_select "div", text: /Tour/
  assert_select "div", text: /Airport Transfer/
end

test "availability: busy result contains link to the blocking booking" do
  TripService.new(booking: @booking, service_type: "tour", date: @today,
                  status: "assigned", driver: @driver1,
                  start_time: "10:00", end_time: "12:00").tap { |s| s.save(validate: false) }

  get admin_operations_availability_url(date: @today, start_time: "10:30", end_time: "11:30")
  assert_response :success
  assert_select "a[href='#{admin_booking_path(@booking, locale: nil)}']"
end

test "availability: external driver badge is shown" do
  @driver1.update!(is_external: true)

  get admin_operations_availability_url(date: @today, start_time: "10:00")
  assert_response :success
  assert_select "span", text: /External/
end
end
