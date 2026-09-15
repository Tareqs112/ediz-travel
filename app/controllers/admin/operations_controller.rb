class Admin::OperationsController < Admin::BaseController
  def availability
    @date      = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @start_time = params[:start_time].presence || "10:00"
    @end_time   = params[:end_time].presence

    @query_start_mins = parse_time_to_mins(@start_time)
    @query_end_mins   = @end_time.present? ? parse_time_to_mins(@end_time) : nil

    # All active drivers and vehicles
    @drivers  = Driver.where(active: true).order(:name)
    @vehicles = Vehicle.where(active: true).order(:name)

    # All non-cancelled, timed services on the date (eager-load booking→customer for links)
    services_on_date = TripService.where(date: @date)
                                  .where.not(status: "cancelled")
                                  .where.not(start_time: nil)
                                  .where.not(end_time: nil)
                                  .includes(booking: :customer)

    # Group all blocking services per resource id
    # Uses blocks_window? when end_time is supplied, blocks_time? otherwise (backward-compat)
    @driver_blocking  = build_blocking_map(services_on_date.where.not(driver_id: nil),  :driver_id)
    @vehicle_blocking = build_blocking_map(services_on_date.where.not(vehicle_id: nil), :vehicle_id)

    render :availability
  end

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
        if a.overlaps_with_buffer?(b)
          conflicts[resource_id] ||= { name: a.send(assoc_name)&.name || "Unknown", service_ids: Set.new }
          conflicts[resource_id][:service_ids] << a.id << b.id
        end
      end
    end

    conflicts
  end

  # Converts a "HH:MM" string to integer minutes-from-midnight.
  # Falls back to 10:00 (600 mins) on unparseable input.
  def parse_time_to_mins(time_str)
    parsed = Time.parse(time_str.to_s)
    parsed.hour * 60 + parsed.min
  rescue ArgumentError
    10 * 60
  end

  # Builds a Hash { resource_id => [array of blocking TripService records] }
  # using blocks_window? when an end time is supplied, otherwise blocks_time? for
  # backward compatibility with the single-point query.
  def build_blocking_map(relation, id_field)
    result = {}
    relation.each do |service|
      blocking = if @query_end_mins.present?
                   service.blocks_window?(@query_start_mins, @query_end_mins)
                 else
                   service.blocks_time?(@query_start_mins)
                 end
      if blocking
        rid = service.send(id_field)
        result[rid] ||= []
        result[rid] << service
      end
    end
    result
  end
end
