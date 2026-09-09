class ToursController < ApplicationController
  def index
    @tours = Tour.where(active: true).with_attached_image

    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @tours = @tours.where("title ILIKE ? OR description ILIKE ?", search_term, search_term)
    end

    if params[:destination_id].present?
      @tours = @tours.where(destination_id: params[:destination_id])
    end

    if params[:tour_type].present?
      @tours = @tours.where(tour_type: params[:tour_type])
    end

    @tours = case params[:sort]
             when "oldest"
               @tours.order(created_at: :asc)
             when "title_asc"
               @tours.order(title: :asc)
             when "title_desc"
               @tours.order(title: :desc)
             else # "newest" or default
               @tours.order(created_at: :desc)
             end
  end

  def show
    @tour = Tour.where(active: true).with_attached_image.find_by!(slug: params[:slug])
    @related_tours = Tour.where(active: true).where.not(id: @tour.id).with_attached_image.limit(3)
  end
end
