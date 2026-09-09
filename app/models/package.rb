class Package < ApplicationRecord
  has_and_belongs_to_many :tours
  has_and_belongs_to_many :destinations
  has_and_belongs_to_many :accommodations
  has_many :trip_inquiries

  has_one_attached :image

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  def to_param
    slug
  end
end
