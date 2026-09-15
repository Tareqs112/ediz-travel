require "test_helper"

class TripServiceTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.create!(name: "John Doe", email: "john@example.com")
    @booking = Booking.create!(customer: @customer, source: 'website', status: 'draft', start_date: Date.today)
    @trip_service = TripService.new(
      booking: @booking,
      service_type: 'airport_transfer',
      date: Date.today,
      status: 'pending'
    )
  end

  test "should be valid with minimal required attributes" do
    assert @trip_service.valid?
  end

  test "should require a booking" do
    @trip_service.booking = nil
    assert_not @trip_service.valid?
  end

  test "should require a service_type" do
    @trip_service.service_type = nil
    assert_not @trip_service.valid?
  end

  test "should require a valid service_type" do
    @trip_service.service_type = 'invalid_type'
    assert_not @trip_service.valid?
  end

  test "should require a date" do
    @trip_service.date = nil
    assert_not @trip_service.valid?
  end

  test "should require a status" do
    @trip_service.status = nil
    assert_not @trip_service.valid?
  end

  test "should require a valid status" do
    @trip_service.status = 'invalid_status'
    assert_not @trip_service.valid?
  end

  test "should be valid with optional driver and vehicle" do
    driver = Driver.create!(name: "Jane Doe", phone: "1234567890")
    vehicle = Vehicle.create!(name: "Mercedes Vito", plate_number: "61 TR 123", vehicle_type: "Minivan")
    
    @trip_service.driver = driver
    @trip_service.vehicle = vehicle
    
    assert @trip_service.valid?
  end

  test "sync_assignment_status updates pending to assigned when both resources present" do
    driver = Driver.create!(name: "Jane Doe", phone: "123")
    vehicle = Vehicle.create!(name: "Mercedes Vito", plate_number: "61 TR 123")
    
    @trip_service.status = "pending"
    @trip_service.driver = driver
    @trip_service.vehicle = vehicle
    @trip_service.save!
    assert_equal "assigned", @trip_service.status
  end

  test "sync_assignment_status updates assigned to pending when driver removed" do
    driver = Driver.create!(name: "Jane Doe", phone: "123")
    vehicle = Vehicle.create!(name: "Mercedes Vito", plate_number: "61 TR 123")
    
    @trip_service.update!(status: "pending", driver: driver, vehicle: vehicle)
    assert_equal "assigned", @trip_service.status

    @trip_service.update!(driver: nil)
    assert_equal "pending", @trip_service.status
  end

  test "sync_assignment_status updates assigned to pending when vehicle removed" do
    driver = Driver.create!(name: "Jane Doe", phone: "123")
    vehicle = Vehicle.create!(name: "Mercedes Vito", plate_number: "61 TR 123")
    
    @trip_service.update!(status: "pending", driver: driver, vehicle: vehicle)
    
    @trip_service.update!(vehicle: nil)
    assert_equal "pending", @trip_service.status
  end

  test "sync_assignment_status does not downgrade in_progress or completed or cancelled" do
    driver = Driver.create!(name: "Jane Doe", phone: "123")
    vehicle = Vehicle.create!(name: "Mercedes Vito", plate_number: "61 TR 123")
    
    %w[in_progress completed cancelled].each do |state|
      @trip_service.update!(status: state, driver: driver, vehicle: vehicle)
      @trip_service.update!(driver: nil)
      assert_equal state, @trip_service.status
    end
  end

  test "should be valid with missing start or end times" do
    @trip_service.start_time = nil
    @trip_service.end_time = "15:00"
    assert @trip_service.valid?

    @trip_service.start_time = "12:00"
    @trip_service.end_time = nil
    assert @trip_service.valid?
  end

  test "should require end_time to be strictly after start_time" do
    @trip_service.start_time = "12:00"
    
    # Valid
    @trip_service.end_time = "12:01"
    assert @trip_service.valid?
    
    # Invalid (equal)
    @trip_service.end_time = "12:00"
    assert_not @trip_service.valid?
    assert_includes @trip_service.errors[:end_time], "must be after start time"

    # Invalid (before)
    @trip_service.end_time = "11:59"
    assert_not @trip_service.valid?
    assert_includes @trip_service.errors[:end_time], "must be after start time"
  end

test "consistency: overlaps_with_buffer? and blocks_time? share exact semantics at boundaries" do
  driver = Driver.create!(name: "Test Driver", phone: "123")
  
  base_service = TripService.create!(booking: @booking, service_type: 'tour', status: 'pending', date: Date.today, driver: driver, start_time: "10:00", end_time: "12:00")
  
  # EXACTLY 45 MINUTES (ALLOWED/AVAILABLE)
  # Service starting at 12:45
  s_45 = TripService.new(booking: @booking, service_type: 'tour', status: 'pending', date: Date.today, driver: driver, start_time: "12:45", end_time: "14:00")
  # Time query at 12:45
  q_45 = 12 * 60 + 45
  
  assert_not base_service.overlaps_with_buffer?(s_45)
  assert_not base_service.blocks_time?(q_45)

  # 44 MINUTES (INSUFFICIENT BUFFER - BUSY/CONFLICT)
  # Service starting at 12:44
  s_44 = TripService.new(booking: @booking, service_type: 'tour', status: 'pending', date: Date.today, driver: driver, start_time: "12:44", end_time: "14:00")
  # Time query at 12:44
  q_44 = 12 * 60 + 44
  
  assert base_service.overlaps_with_buffer?(s_44)
  assert base_service.blocks_time?(q_44)

  # 46 MINUTES (ALLOWED/AVAILABLE)
  # Service starting at 12:46
  s_46 = TripService.new(booking: @booking, service_type: 'tour', status: 'pending', date: Date.today, driver: driver, start_time: "12:46", end_time: "14:00")
  # Time query at 12:46
  q_46 = 12 * 60 + 46
  
  assert_not base_service.overlaps_with_buffer?(s_46)
  assert_not base_service.blocks_time?(q_46)

  # LITERAL OVERLAP (BUSY/CONFLICT)
  # Service starting at 11:30
  s_overlap = TripService.new(booking: @booking, service_type: 'tour', status: 'pending', date: Date.today, driver: driver, start_time: "11:30", end_time: "13:00")
  # Time query at 11:30
  q_overlap = 11 * 60 + 30
  
  assert base_service.overlaps_with_buffer?(s_overlap)
  assert base_service.blocks_time?(q_overlap)
end
end
