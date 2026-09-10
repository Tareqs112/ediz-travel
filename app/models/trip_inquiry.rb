class TripInquiry < ApplicationRecord
  validates :pickup_location, presence: true, if: -> { airport_transfer? || private_transport? || car_rental? || chauffeured_car? }
  validates :dropoff_location, presence: true, if: -> { airport_transfer? || private_transport? || car_rental? || chauffeured_car? }
  validates :pickup_time, presence: true, if: -> { airport_transfer? || private_transport? || car_rental? || chauffeured_car? }
  enum :inquiry_type, { general: 'general', airport_transfer: 'airport_transfer', private_transport: 'private_transport', car_rental: 'car_rental', chauffeured_car: 'chauffeured_car' }
  belongs_to :package, optional: true
  belongs_to :accommodation, optional: true
  has_one :booking
  VALID_STATUSES = %w[new contacted quoted confirmed completed cancelled].freeze

  validates :customer_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :travel_date, presence: true
  validates :travelers_count, presence: true, numericality: { greater_than: 0 }
  validates :duration_days, numericality: { greater_than: 0 }, allow_nil: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
end
