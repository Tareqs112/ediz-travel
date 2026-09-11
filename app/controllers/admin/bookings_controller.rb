class Admin::BookingsController < Admin::BaseController
  before_action :set_booking, only: %i[show edit update destroy]

  def index
    @bookings = Booking.includes(:customer, :trip_services).order(created_at: :desc)

    if params[:status].present? && Booking::VALID_STATUSES.include?(params[:status])
      @bookings = @bookings.where(status: params[:status])
    end

    if params[:source].present? && Booking::VALID_SOURCES.include?(params[:source])
      @bookings = @bookings.where(source: params[:source])
    end
  end

  def show
  end

  def new
    @booking = Booking.new
  end

  def edit
  end

  def create
    @booking = Booking.new(booking_params)

    if @booking.save
      redirect_to admin_booking_path(@booking), notice: "Booking was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @booking.update(booking_params)
      redirect_to admin_booking_path(@booking), notice: "Booking was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @booking.destroy
      redirect_to admin_bookings_path, notice: "Booking was successfully deleted."
    else
      redirect_to admin_booking_path(@booking), alert: @booking.errors.full_messages.to_sentence
    end
  end

  private

  def set_booking
    @booking = Booking.includes(:customer, :booking_request, :trip_inquiry, trip_services: [:driver, :vehicle]).find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:customer_id, :source, :status, :start_date, :end_date, :notes)
  end
end
