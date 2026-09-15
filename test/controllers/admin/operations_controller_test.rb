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
    assert_select "h1", text: /Daily Operations/ # wait, the H1 is populated via yield in layout. Let's check title
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
  get admin_operations_availability_url(date: @today, time: "10:00")
  assert_response :success
  assert_select "h1", text: /Availability Lookup/
  assert_select "div", text: /#{@driver1.name}/
  assert_select "div", text: /#{@vehicle1.name}/
end
end
