class Driver < ApplicationRecord
  validates :name, presence: true
  validates :phone, presence: true

  # Set default values
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.active = true if active.nil?
  end
end
