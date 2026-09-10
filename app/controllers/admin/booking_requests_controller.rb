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

  def convert_to_booking
    @booking_request = BookingRequest.find(params[:id])

    if @booking_request.booking.present?
      redirect_to admin_booking_path(@booking_request.booking), notice: "This request has already been converted to a booking."
      return
    end

    customer = nil
    if @booking_request.email.present?
      email_matches = Customer.where(email: @booking_request.email)
      customer = email_matches.first if email_matches.count == 1
    end

    if customer.nil? && @booking_request.phone.present?
      phone_matches = Customer.where(phone: @booking_request.phone)
      customer = phone_matches.first if phone_matches.count == 1
    end

    if customer.nil?
      customer = Customer.create!(
        name: @booking_request.customer_name,
        email: @booking_request.email,
        phone: @booking_request.phone,
        notes: "Created from Booking Request ##{@booking_request.id}"
      )
    end

    booking = Booking.create!(
      customer: customer,
      booking_request: @booking_request,
      source: 'website',
      status: 'draft',
      start_date: @booking_request.travel_date,
      notes: @booking_request.notes
    )

    redirect_to admin_booking_path(booking), notice: "Booking successfully created from request."
  end

  private

  def set_booking_request
    @booking_request = BookingRequest.find(params[:id])
  end

  def booking_request_params
    params.require(:booking_request).permit(:status)
  end
end
