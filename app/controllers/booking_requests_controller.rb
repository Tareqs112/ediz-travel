class BookingRequestsController < ApplicationController
  before_action :set_tour

  def new
    @booking_request = @tour.booking_requests.build
  end

  def create
    @booking_request = @tour.booking_requests.build(booking_request_params)
    @booking_request.status = "new"

    if @booking_request.save
      redirect_to tour_booking_request_path(@tour, @booking_request)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @booking_request = @tour.booking_requests.find(params[:id])
  end

  private

  def set_tour
    @tour = Tour.where(active: true).find_by!(slug: params[:tour_slug])
  end

  def booking_request_params
    params.require(:booking_request).permit(
      :customer_name,
      :email,
      :phone,
      :travel_date,
      :travelers_count,
      :preferred_language,
      :notes
    )
  end
end
