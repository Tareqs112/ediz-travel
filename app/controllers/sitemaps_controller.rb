class SitemapsController < ApplicationController
  def index
    @tours = Tour.where(active: true)
    @travel_guides = TravelGuide.published
    @packages = Package.where(active: true)
    @accommodations = Accommodation.where(active: true)
    
    @locales = [:en, :ar, :tr]

    respond_to do |format|
      format.xml
    end
  end
end
