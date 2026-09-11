class Admin::VehicleOperationsController < Admin::BaseController
  before_action :set_vehicle

  def show
    begin
      @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    rescue Date::Error
      @date = Date.today
    end

    @services = @vehicle.trip_services
      .where(date: @date)
      .includes(booking: [:customer, :booking_request, :trip_inquiry], driver: [])
      .order(:start_time, :created_at)

    @total = @services.reject { |s| s.status == "cancelled" }.size
    @conflicts = detect_conflicts
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def detect_conflicts
    conflicts = Set.new
    timed = @services.select { |s| s.status != "cancelled" && s.start_time.present? && s.end_time.present? }

    timed.combination(2).each do |a, b|
      if a.start_time < b.end_time && b.start_time < a.end_time
        conflicts << a.id << b.id
      end
    end

    conflicts
  end
end
