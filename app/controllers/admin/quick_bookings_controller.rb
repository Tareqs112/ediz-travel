class Admin::QuickBookingsController < Admin::BaseController
  def new
    @quick_booking_form = QuickBookingForm.new
    # Default to today
    @quick_booking_form.service_date = Date.current
  end

  def create
    @quick_booking_form = QuickBookingForm.new(quick_booking_params)

    if @quick_booking_form.save
      redirect_to admin_booking_path(@quick_booking_form.booking), notice: "Quick Booking was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def quick_booking_params
    params.require(:quick_booking_form).permit(
      :customer_name, :customer_phone, :customer_email,
      :source, :status, :start_date, :end_date, :total_price, :currency,
      :service_type, :service_date, :start_time, :end_time,
      :pickup_location, :dropoff_location, :driver_id, :vehicle_id, :notes
    )
  end
end
