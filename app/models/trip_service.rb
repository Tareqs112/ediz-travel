class TripService < ApplicationRecord
  belongs_to :booking
  belongs_to :driver, optional: true
  belongs_to :vehicle, optional: true

  VALID_SERVICE_TYPES = %w[tour airport_transfer private_transfer chauffeured_car car_rental accommodation other].freeze
  VALID_STATUSES = %w[pending assigned in_progress completed cancelled].freeze

  validates :service_type, presence: true, inclusion: { in: VALID_SERVICE_TYPES }
  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validate :end_time_after_start_time

  before_validation :sync_assignment_status

  def end_time_after_start_time
    if start_time.present? && end_time.present? && end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def sync_assignment_status
    if status == "pending" && driver_id.present? && vehicle_id.present?
      self.status = "assigned"
    elsif status == "assigned" && (driver_id.blank? || vehicle_id.blank?)
      self.status = "pending"
    end
  end

  def conflicting_driver_services
    return TripService.none if status == 'cancelled' || driver_id.nil? || start_time.nil? || end_time.nil?
    TripService.where(driver_id: driver_id, date: date)
               .where.not(id: id)
               .where.not(status: 'cancelled')
               .where.not(start_time: nil)
               .where.not(end_time: nil)
               .where("start_time < ? AND end_time > ?", end_time, start_time)
  end

  def conflicting_vehicle_services
    return TripService.none if status == 'cancelled' || vehicle_id.nil? || start_time.nil? || end_time.nil?
    TripService.where(vehicle_id: vehicle_id, date: date)
               .where.not(id: id)
               .where.not(status: 'cancelled')
               .where.not(start_time: nil)
               .where.not(end_time: nil)
               .where("start_time < ? AND end_time > ?", end_time, start_time)
  end
end
