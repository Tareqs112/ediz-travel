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

  def convert_to_booking
    @trip_inquiry = TripInquiry.find(params[:id])

    if @trip_inquiry.booking.present?
      redirect_to admin_booking_path(@trip_inquiry.booking), notice: "This inquiry has already been converted to a booking."
      return
    end

    customer = nil
    if @trip_inquiry.email.present?
      email_matches = Customer.where(email: @trip_inquiry.email)
      customer = email_matches.first if email_matches.count == 1
    end

    if customer.nil? && @trip_inquiry.phone.present?
      phone_matches = Customer.where(phone: @trip_inquiry.phone)
      customer = phone_matches.first if phone_matches.count == 1
    end

    if customer.nil?
      customer = Customer.create!(
        name: @trip_inquiry.customer_name,
        email: @trip_inquiry.email,
        phone: @trip_inquiry.phone,
        notes: "Created from Trip Inquiry ##{@trip_inquiry.id}"
      )
    end

    booking = Booking.create!(
      customer: customer,
      trip_inquiry: @trip_inquiry,
      source: 'website',
      status: 'draft',
      start_date: @trip_inquiry.travel_date,
      notes: @trip_inquiry.notes
    )

    redirect_to admin_booking_path(booking), notice: "Booking successfully created from inquiry."
  end

  private

  def set_trip_inquiry
    @trip_inquiry = TripInquiry.find(params[:id])
  end

  def trip_inquiry_params
    params.require(:trip_inquiry).permit(:status)
  end
end
