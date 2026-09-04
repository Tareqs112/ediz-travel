class PagesController < ApplicationController
  def home
    @featured_tours = Tour.where(active: true).order(created_at: :asc).limit(3)
  end
end
