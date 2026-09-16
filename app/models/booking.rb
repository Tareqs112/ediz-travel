class Booking < ApplicationRecord
  belongs_to :customer
  belongs_to :booking_request, optional: true
  belongs_to :trip_inquiry, optional: true
  has_many :trip_services, dependent: :restrict_with_error


  VALID_SOURCES = %w[website whatsapp phone walk_in partner other].freeze
  VALID_STATUSES = %w[draft confirmed active completed cancelled].freeze

  validates :source, presence: true, inclusion: { in: VALID_SOURCES }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  # Prevent a single lead from creating multiple bookings
  validates :booking_request_id, uniqueness: true, allow_nil: true
  validates :trip_inquiry_id, uniqueness: true, allow_nil: true

  def active_trip_services
    trip_services.reject { |s| s.status == 'cancelled' }
  end

  def total_estimated_cost
    active = active_trip_services
    return nil if active.empty?
    return nil if active.all? { |s| s.estimated_cost.nil? }

    active.sum { |s| s.estimated_cost || 0 }
  end

  def approximate_margin
    return nil if total_price.nil? || total_estimated_cost.nil?
    total_price - total_estimated_cost
  end

  def has_incomplete_costs?
    active = active_trip_services
    active.any? { |s| s.estimated_cost.nil? } && active.any? { |s| s.estimated_cost.present? }
  end
end
