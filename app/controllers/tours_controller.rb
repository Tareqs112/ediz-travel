class ToursController < ApplicationController
  def index
    @tours = Tour.where(active: true).order(created_at: :desc)
  end

  def show
    @tour = Tour.where(active: true).find_by!(slug: params[:slug])
  end
end
