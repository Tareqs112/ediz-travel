class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip

    if @query.present?
      term = "%#{@query}%"
      @tours = Tour.where(active: true).where("title ILIKE ? OR description ILIKE ?", term, term).with_attached_image
      @packages = Package.where(active: true).where("title ILIKE ? OR description ILIKE ?", term, term).with_attached_image
    else
      @tours = Tour.none
      @packages = Package.none
    end
  end
end
