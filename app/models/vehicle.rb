class Vehicle < ApplicationRecord
  validates :name, presence: true
  validates :plate_number, presence: true, uniqueness: true

  # Set default values
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.active = true if active.nil?
  end
end
