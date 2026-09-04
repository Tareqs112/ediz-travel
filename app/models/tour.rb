class Tour < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
  validates :slug, presence: true, uniqueness: true
end
