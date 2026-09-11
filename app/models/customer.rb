class Customer < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error

  validates :name, presence: true
  validates :preferred_language, inclusion: { in: %w[en ar tr] }, allow_nil: true

  # Validating email format but allow blank. No uniqueness enforced (could be shared).
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
end
