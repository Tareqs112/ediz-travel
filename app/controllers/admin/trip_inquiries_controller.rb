class Admin::TripInquiriesController < Admin::BaseController
  before_action :set_trip_inquiry, only: [:show, :update]

  def index
    @trip_inquiries = TripInquiry.order(created_at: :desc)

    if params[:status].present? && TripInquiry::VALID_STATUSES.include?(params[:status])
      @trip_inquiries = @trip_inquiries.where(status: params[:status])
    end

    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @trip_inquiries = @trip_inquiries.where("customer_name ILIKE ? OR email ILIKE ?", search_term, search_term)
    end
  end

  def show
  end

  def update
    if @trip_inquiry.update(trip_inquiry_params)
      redirect_to admin_trip_inquiry_path(@trip_inquiry), notice: "Trip inquiry status was successfully updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_trip_inquiry
    @trip_inquiry = TripInquiry.find(params[:id])
  end

  def trip_inquiry_params
    params.require(:trip_inquiry).permit(:status)
  end
end
