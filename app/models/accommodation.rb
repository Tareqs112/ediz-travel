class Accommodation < ApplicationRecord
  has_and_belongs_to_many :packages
  has_one_attached :image

  enum :accommodation_type, {
    hotel: "hotel",
    apartment: "apartment",
    bungalow: "bungalow",
    chalet: "chalet"
  }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :accommodation_type, presence: true

  def to_param
    slug
  end
end
