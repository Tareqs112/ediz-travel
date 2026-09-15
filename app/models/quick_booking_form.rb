class QuickBookingForm
  include ActiveModel::Model

  # Customer Fields
  attr_accessor :customer_name, :customer_phone, :customer_email
  
  # Booking Fields
  attr_accessor :source, :status, :start_date, :end_date, :total_price, :currency

  # TripService Fields
  attr_accessor :service_type, :service_date, :start_time, :end_time
  attr_accessor :pickup_location, :dropoff_location, :driver_id, :vehicle_id, :notes

  # Internal Readers
  attr_reader :customer, :booking, :trip_service

  # Validations
  validates :customer_name, presence: true
  validates :customer_phone, presence: true
  validates :source, presence: true, inclusion: { in: Booking::VALID_SOURCES }
  validates :status, presence: true, inclusion: { in: Booking::VALID_STATUSES }
  validates :service_type, presence: true
  validates :service_date, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0, allow_nil: true, allow_blank: true }

  def initialize(attributes = {})
    super
    @source ||= "whatsapp"
    @status ||= "confirmed"
    @currency ||= "USD"
    @service_type ||= "airport_transfer"
  end

  def save
    return false unless valid?
    
    ActiveRecord::Base.transaction do
      @customer = find_or_build_customer
      unless @customer.save
        promote_errors(@customer)
        raise ActiveRecord::Rollback
      end

      @booking = @customer.bookings.build(
        source: source,
        status: status,
        start_date: start_date.presence,
        end_date: end_date.presence,
        total_price: total_price.presence,
        currency: currency.presence
      )
      
      unless @booking.save
        promote_errors(@booking)
        raise ActiveRecord::Rollback
      end

      @trip_service = @booking.trip_services.build(
        service_type: service_type,
        date: service_date,
        start_time: start_time.presence,
        end_time: end_time.presence,
        pickup_location: pickup_location.presence,
        dropoff_location: dropoff_location.presence,
        driver_id: driver_id.presence,
        vehicle_id: vehicle_id.presence,
        notes: notes.presence,
        status: "pending" # default status for new trip services
      )
      
      unless @trip_service.save
        promote_errors(@trip_service)
        raise ActiveRecord::Rollback
      end
      
      true
    end || false
  end

  private

  def find_or_build_customer
    normalized = normalize_phone(customer_phone)
    if normalized.present?
      variations = phone_variations(normalized)
      existing = Customer.where("regexp_replace(phone, '[^0-9]', '', 'g') IN (?)", variations).first
      return existing if existing
    end

    Customer.new(
      name: customer_name,
      phone: customer_phone,
      email: customer_email.presence
    )
  end

  def normalize_phone(phone)
    return nil if phone.blank?
    phone.to_s.gsub(/[^0-9]/, "")
  end
  
  def phone_variations(num)
    if num.start_with?("90") && num.length == 12
      [num, "0#{num[2..]}"]
    elsif num.start_with?("0") && num.length == 11
      [num, "90#{num[1..]}"]
    else
      [num]
    end
  end
  
  def promote_errors(record)
    record.errors.each do |error|
      errors.add(:base, "#{record.class.model_name.human} error: #{error.message}")
    end
  end
end
