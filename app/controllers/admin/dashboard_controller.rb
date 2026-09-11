class Admin::DashboardController < Admin::BaseController
  def index
    @today = Date.today
    @tomorrow = Date.tomorrow

    # TODAY
    @todays_services = TripService.where(date: @today)
      .includes(booking: [:customer], driver: [], vehicle: [])
      .order(:start_time, :created_at)

    @today_total = @todays_services.reject { |s| s.status == 'cancelled' }.size
    @today_needs_driver = @todays_services.count { |s| s.status != 'cancelled' && s.driver_id.nil? }
    @today_needs_vehicle = @todays_services.count { |s| s.status != 'cancelled' && s.vehicle_id.nil? }
    @today_in_progress = @todays_services.count { |s| s.status == 'in_progress' }
    @today_completed = @todays_services.count { |s| s.status == 'completed' }
    
    @today_driver_conflicts, @today_vehicle_conflicts = detect_conflicts(@todays_services)
    @today_conflicts_count = @today_driver_conflicts.size + @today_vehicle_conflicts.size

    @today_fully_assigned = @todays_services.count { |s| s.status != 'cancelled' && s.driver_id.present? && s.vehicle_id.present? }

    @urgent_services = @todays_services.select do |s|
      s.status != 'cancelled' && (
        s.driver_id.nil? || 
        s.vehicle_id.nil? || 
        @today_driver_conflicts[s.driver_id]&.dig(:service_ids)&.include?(s.id) ||
        @today_vehicle_conflicts[s.vehicle_id]&.dig(:service_ids)&.include?(s.id)
      )
    end

    # TOMORROW
    @tomorrows_services = TripService.where(date: @tomorrow).includes(:driver, :vehicle)
    @tomorrow_total = @tomorrows_services.reject { |s| s.status == 'cancelled' }.size
    @tomorrow_fully_assigned = @tomorrows_services.count { |s| s.status != 'cancelled' && s.driver_id.present? && s.vehicle_id.present? }
    @tomorrow_needs_driver = @tomorrows_services.count { |s| s.status != 'cancelled' && s.driver_id.nil? }
    @tomorrow_needs_vehicle = @tomorrows_services.count { |s| s.status != 'cancelled' && s.vehicle_id.nil? }
    
    tomorrow_dc, tomorrow_vc = detect_conflicts(@tomorrows_services)
    @tomorrow_conflicts_count = tomorrow_dc.size + tomorrow_vc.size
  end

  private

  def detect_conflicts(services)
    driver_conflicts = {}
    vehicle_conflicts = {}

    timed = services.select { |s| s.status != "cancelled" && s.start_time.present? && s.end_time.present? }

    timed.combination(2).each do |a, b|
      if a.start_time < b.end_time && b.start_time < a.end_time
        if a.driver_id && a.driver_id == b.driver_id
          driver_conflicts[a.driver_id] ||= { name: a.driver.name, service_ids: Set.new }
          driver_conflicts[a.driver_id][:service_ids] << a.id << b.id
        end
        if a.vehicle_id && a.vehicle_id == b.vehicle_id
          vehicle_conflicts[a.vehicle_id] ||= { name: a.vehicle.name, service_ids: Set.new }
          vehicle_conflicts[a.vehicle_id][:service_ids] << a.id << b.id
        end
      end
    end

    [driver_conflicts, vehicle_conflicts]
  end
end
