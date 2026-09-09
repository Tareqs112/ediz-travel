class Tour < ApplicationRecord
  has_and_belongs_to_many :packages
  belongs_to :destination, optional: true
  has_many :booking_requests, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :slug, presence: true, uniqueness: true

  has_one_attached :image

  def to_param
    slug
  end
end
