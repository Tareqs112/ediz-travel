class Tour < ApplicationRecord
  extend Mobility
  fixed_translates :title, :description, :cancellation_policy, :meeting_point,
             :included, :excluded, :highlights, :itinerary,
             fallbacks: { ar: :en, tr: :en }

  has_and_belongs_to_many :packages
  belongs_to :destination, optional: true
  has_many :booking_requests, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :slug, presence: true, uniqueness: true

  has_one_attached :image

  before_save :sync_legacy_columns

  def to_param
    slug
  end

  private

  def sync_legacy_columns
    write_attribute(:title, title_en)
    write_attribute(:description, description_en)
    write_attribute(:cancellation_policy, cancellation_policy_en)
    write_attribute(:meeting_point, meeting_point_en)
    write_attribute(:included, included_en)
    write_attribute(:excluded, excluded_en)
    write_attribute(:highlights, highlights_en)
    write_attribute(:itinerary, itinerary_en)
  end
end
