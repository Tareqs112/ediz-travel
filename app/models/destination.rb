class Destination < ApplicationRecord
  has_and_belongs_to_many :packages
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  has_one_attached :image
  has_many :tours, dependent: :nullify

  def to_param
    slug
  end
end
