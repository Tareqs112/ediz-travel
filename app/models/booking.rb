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
end
