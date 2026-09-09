class TravelGuidesController < ApplicationController
  def index
    @travel_guides = TravelGuide.published.with_attached_image.order(published_at: :desc, created_at: :desc)
  end

  def show
    @travel_guide = TravelGuide.published.with_attached_image.find_by!(slug: params[:slug])
    @related_guides = TravelGuide.published.where.not(id: @travel_guide.id).with_attached_image.order(published_at: :desc).limit(3)
  end
end
