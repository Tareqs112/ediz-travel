class CommercialVehicle < ApplicationRecord
  extend Mobility
  fixed_translates :name, :description, fallbacks: { ar: :en, tr: :en }

  has_one_attached :image

  validates :name, presence: true
  validates :category, presence: true, inclusion: { in: %w[chauffeured self_drive] }
  validates :price_from, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :passenger_capacity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :luggage_capacity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(active: true) }
  scope :chauffeured, -> { where(category: 'chauffeured') }
  scope :self_drive, -> { where(category: 'self_drive') }

  before_save :sync_legacy_columns

  private

  def sync_legacy_columns
    write_attribute(:name, name_en)
    write_attribute(:description, description_en)
  end
end
