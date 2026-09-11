class Admin::TripServicesController < Admin::BaseController
  before_action :set_booking
  before_action :set_trip_service, only: %i[edit update destroy]

  def new
    @trip_service = @booking.trip_services.build(date: @booking.start_date || Date.today)
  end

  def edit
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

  def trip_service_params
    params.require(:trip_service).permit(
      :service_type, :date, :start_time, :end_time,
      :pickup_location, :dropoff_location,
      :driver_id, :vehicle_id, :status, :notes
    )
  end
end
