class PagesController < ApplicationController
  def home
    @featured_tours = Tour.where(active: true).with_attached_image.order(created_at: :asc).limit(3)
    @travel_guides = TravelGuide.published.with_attached_image.order(published_at: :desc, created_at: :desc).limit(3)
  end

  
  
  def about
  end

  def contact
  end

  def faq
  end
end
