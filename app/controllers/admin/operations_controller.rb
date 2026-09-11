class Admin::OperationsController < Admin::BaseController
  def index
    begin
      @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    rescue Date::Error
      @date = Date.today
    end

    @services = TripService
      .where(date: @date)
      .includes(booking: [:customer, :booking_request, :trip_inquiry], driver: [], vehicle: [])
      .order(:start_time, :created_at)

    # Summary stats (computed from already-loaded collection)
    active_services = @services.reject { |s| s.status == "cancelled" }
    @total        = @services.size
    @assigned     = active_services.count { |s| s.driver_id.present? && s.vehicle_id.present? }
    @needs_driver = active_services.count { |s| s.driver_id.nil? }
    @needs_vehicle = active_services.count { |s| s.vehicle_id.nil? }
    @in_progress  = @services.count { |s| s.status == "in_progress" }
    @completed    = @services.count { |s| s.status == "completed" }

    # Conflict detection
    @driver_conflicts  = detect_conflicts(:driver_id, :driver)
    @vehicle_conflicts = detect_conflicts(:vehicle_id, :vehicle)
  end

  private

  # Detects overlapping time assignments for drivers or vehicles on the selected date.
  # Returns a Hash: { resource_id => [array of conflicting TripService pairs info] }
  def detect_conflicts(id_field, assoc_name)
    conflicts = {}

    # Only consider non-cancelled services that have both start_time and end_time
    timed = @services.select { |s| s.status != "cancelled" && s.start_time.present? && s.end_time.present? && s.send(id_field).present? }

    # Group by the resource (driver or vehicle)
    grouped = timed.group_by { |s| s.send(id_field) }

    grouped.each do |resource_id, services|
      next if services.size < 2

      # Check each pair for overlap
      services.combination(2).each do |a, b|
        if times_overlap?(a.start_time, a.end_time, b.start_time, b.end_time)
          conflicts[resource_id] ||= { name: a.send(assoc_name)&.name || "Unknown", service_ids: Set.new }
          conflicts[resource_id][:service_ids] << a.id << b.id
        end
      end
    end

    conflicts
  end

  def times_overlap?(start_a, end_a, start_b, end_b)
    start_a < end_b && start_b < end_a
  end
end
