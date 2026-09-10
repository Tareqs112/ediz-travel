class PagesController < ApplicationController
  def home
    # 4 Signature Experiences
    @featured_tours = Tour.featured.limit(4)
    
    # 3 Travel Guides
    @travel_guides = TravelGuide.published.limit(3)
    
    # Specific tours for the Discover editorial section
    @uzungol = Tour.find_by(slug: 'uzungol-tour')
    @ayder = Tour.find_by(slug: 'ayder-firtina')
    @sumela = Tour.find_by(slug: 'sumela-karaca')
    @trabzon = Tour.find_by(slug: 'trabzon-city-tour')
  end

  def about
  end

  def contact
    @contact_message = ContactMessage.new
  end

  def faq
  end
end
