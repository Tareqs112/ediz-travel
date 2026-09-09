class AccommodationsController < ApplicationController
  def index
    @type = params[:type]
    
    @accommodations = Accommodation.where(active: true).with_attached_image
    
    if @type.present? && Accommodation.accommodation_types.keys.include?(@type)
      @accommodations = @accommodations.where(accommodation_type: @type)
    end
    
    @accommodations = @accommodations.order(featured: :desc, name: :asc)
  end

  def show
    @accommodation = Accommodation.where(active: true).with_attached_image.find_by!(slug: params[:slug])
  end
end
