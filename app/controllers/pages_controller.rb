class PagesController < ApplicationController
  def home
    @featured_tours = Tour.where(active: true).order(created_at: :asc).limit(3)
  end

  def plan_your_trip
  end

  def airport_transfer
  end

  def private_tours
  end

  def packages
  end

  def about
  end

  def contact
  end

  def faq
  end
end
