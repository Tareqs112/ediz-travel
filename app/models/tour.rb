class Tour < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
  validates :slug, presence: true, uniqueness: true

  has_one_attached :image

  def to_param
    slug
  end
end
