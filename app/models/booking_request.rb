class BookingRequest < ApplicationRecord
  belongs_to :tour
  has_one :booking

  VALID_STATUSES = %w[new contacted quoted confirmed completed cancelled].freeze

  validates :customer_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :travel_date, presence: true
  validates :travelers_count, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
end
