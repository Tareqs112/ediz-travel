class Admin::TripServicesController < Admin::BaseController
  before_action :set_booking
  before_action :set_trip_service, only: %i[edit update destroy]

  def new
  if params[:trip_service].present?
    @trip_service = @booking.trip_services.build(trip_service_params_for_check)
  else
    @trip_service = @booking.trip_services.build(date: @booking.start_date || Date.today)
  end
  
  respond_to do |format|
    format.html
    format.json { render json: conflict_check_response(@trip_service) }
  end
end

def edit
  @trip_service.assign_attributes(trip_service_params_for_check) if params[:trip_service].present?
  
  respond_to do |format|
    format.html
    format.json { render json: conflict_check_response(@trip_service) }
  end
end


  def create
    @trip_service = @booking.trip_services.build(trip_service_params)

    if @trip_service.save
      redirect_to admin_booking_path(@booking), notice: "Service was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @trip_service.update(trip_service_params)
      redirect_to admin_booking_path(@booking), notice: "Service was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trip_service.destroy
    redirect_to admin_booking_path(@booking), notice: "Service was successfully removed."
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
  end

  def set_trip_service
    @trip_service = @booking.trip_services.find(params[:id])
  end

  def trip_service_params_for_check
  params.require(:trip_service).permit(
    :date, :start_time, :end_time, :driver_id, :vehicle_id
  )
end

def conflict_check_response(service)
  service.valid? # trigger validations including no_literal_overlap

  driver_conflict = nil
  vehicle_conflict = nil

  if service.driver_id.present?
    overlapping = TripService.where(driver_id: service.driver_id, date: service.date)
                             .where.not(id: service.id)
                             .where.not(status: 'cancelled')
                             .where.not(start_time: nil)
                             .where.not(end_time: nil)
                             .select { |s| service.literal_overlap?(s) }
    driver_conflict = overlapping.first
  end

  if service.vehicle_id.present?
    overlapping = TripService.where(vehicle_id: service.vehicle_id, date: service.date)
                             .where.not(id: service.id)
                             .where.not(status: 'cancelled')
                             .where.not(start_time: nil)
                             .where.not(end_time: nil)
                             .select { |s| service.literal_overlap?(s) }
    vehicle_conflict = overlapping.first
  end

  if driver_conflict || vehicle_conflict
    html = render_to_string(partial: "admin/trip_services/conflict_warning", locals: { driver_conflict: driver_conflict, vehicle_conflict: vehicle_conflict }, formats: [:html])
    { has_conflict: true, html: html }
  else
    { has_conflict: false, html: "" }
  end
end

  def trip_service_params
    params.require(:trip_service).permit(
      :service_type, :date, :start_time, :end_time,
      :pickup_location, :dropoff_location,
      :driver_id, :vehicle_id, :status, :notes, :estimated_cost
    )
  end
end
