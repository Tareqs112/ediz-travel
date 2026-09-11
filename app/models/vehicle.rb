class Vehicle < ApplicationRecord
  validates :name, presence: true
  validates :plate_number, presence: true, uniqueness: true

  has_many :trip_services, dependent: :restrict_with_error
  has_many :todays_trip_services, -> { where(date: Date.today) }, class_name: "TripService"


  # Set default values
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.active = true if active.nil?
  end
end
