class Admin::BookingRequestsController < Admin::BaseController
  before_action :set_booking_request, only: [:show, :update]

  def index
    @booking_requests = BookingRequest.order(created_at: :desc)

    if params[:status].present? && BookingRequest::VALID_STATUSES.include?(params[:status])
      @booking_requests = @booking_requests.where(status: params[:status])
    end

    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @booking_requests = @booking_requests.where("customer_name ILIKE ? OR email ILIKE ?", search_term, search_term)
    end
  end

  def show
  end

  def update
    if @booking_request.update(booking_request_params)
      redirect_to admin_booking_request_path(@booking_request), notice: "Booking request status was successfully updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_booking_request
    @booking_request = BookingRequest.find(params[:id])
  end

  def booking_request_params
    params.require(:booking_request).permit(:status)
  end
end
