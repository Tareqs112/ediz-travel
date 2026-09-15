class TripService < ApplicationRecord
  belongs_to :booking
  belongs_to :driver, optional: true
  belongs_to :vehicle, optional: true

  VALID_SERVICE_TYPES = %w[tour airport_transfer private_transfer chauffeured_car car_rental accommodation other].freeze
  VALID_STATUSES = %w[pending assigned in_progress completed cancelled].freeze
  
  BUFFER_MINUTES = 45

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
    services = TripService.where(driver_id: driver_id, date: date)
                          .where.not(id: id)
                          .where.not(status: 'cancelled')
                          .where.not(start_time: nil)
                          .where.not(end_time: nil)
                          
    conflict_ids = services.select { |s| overlaps_with_buffer?(s) }.map(&:id)
    TripService.where(id: conflict_ids)
  end

  def conflicting_vehicle_services
    return TripService.none if status == 'cancelled' || vehicle_id.nil? || start_time.nil? || end_time.nil?
    services = TripService.where(vehicle_id: vehicle_id, date: date)
                          .where.not(id: id)
                          .where.not(status: 'cancelled')
                          .where.not(start_time: nil)
                          .where.not(end_time: nil)
                          
    conflict_ids = services.select { |s| overlaps_with_buffer?(s) }.map(&:id)
    TripService.where(id: conflict_ids)
  end

  def blocked_interval
  return nil if start_time.nil? || end_time.nil?
  my_start_mins = start_time.hour * 60 + start_time.min
  my_end_mins = end_time.hour * 60 + end_time.min
  [(my_start_mins - BUFFER_MINUTES), (my_end_mins + BUFFER_MINUTES)]
end

def literal_overlap?(other_service)
  return false if start_time.nil? || end_time.nil? || other_service.start_time.nil? || other_service.end_time.nil?
  
  my_start_mins = start_time.hour * 60 + start_time.min
  my_end_mins = end_time.hour * 60 + end_time.min
  
  other_start_mins = other_service.start_time.hour * 60 + other_service.start_time.min
  other_end_mins = other_service.end_time.hour * 60 + other_service.end_time.min
  
  other_start_mins < my_end_mins && other_end_mins > my_start_mins
end

def overlaps_with_buffer?(other_service)
  interval = blocked_interval
  return false unless interval
  return false if other_service.start_time.nil? || other_service.end_time.nil?
  
  other_start_mins = other_service.start_time.hour * 60 + other_service.start_time.min
  other_end_mins = other_service.end_time.hour * 60 + other_service.end_time.min
  
  other_start_mins < interval[1] && other_end_mins > interval[0]
end

# Checks if a specific time (in minutes from midnight) is blocked by this service
# respecting the operational buffer.
def blocks_time?(query_mins)
  interval = blocked_interval
  return false unless interval
  
  query_mins > interval[0] && query_mins < interval[1]
end
end
