class TripInquiriesController < ApplicationController
  def new
    @trip_inquiry = TripInquiry.new(package_id: params[:package_id], accommodation_id: params[:accommodation_id], inquiry_type: params[:inquiry_type] || 'general')
  end

  def create
    @trip_inquiry = TripInquiry.new(trip_inquiry_params)
    @trip_inquiry.status = "new"

    if @trip_inquiry.save
      redirect_to trip_inquiry_path(@trip_inquiry)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @trip_inquiry = TripInquiry.find(params[:id])
  end

  private

  def trip_inquiry_params
    params.require(:trip_inquiry).permit(
      :customer_name,
      :email,
      :phone,
      :travel_date,
      :travelers_count,
      :preferred_language,
      :duration_days,
      :interests,
      :notes,
      :package_id, :accommodation_id,
      :inquiry_type, :pickup_time, :pickup_location, :dropoff_location, :flight_details, :vehicle_preference
    )
  end
end
