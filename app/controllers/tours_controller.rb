class ToursController < ApplicationController
  def index
    @tours = Tour.where(active: true).order(created_at: :desc)
  end
end
