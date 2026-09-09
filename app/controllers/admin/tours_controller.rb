class Admin::ToursController < Admin::BaseController
  before_action :set_tour, only: [:show, :edit, :update, :destroy]

  def index
    @tours = Tour.includes(:destination).order(created_at: :desc)
  end

  def show
  end

  def new
    @tour = Tour.new
  end

  def create
    @tour = Tour.new(tour_params)
    if @tour.save
      redirect_to admin_tour_path(@tour), notice: "Tour was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tour.update(tour_params)
      redirect_to admin_tour_path(@tour), notice: "Tour was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tour.destroy
    redirect_to admin_tours_path, notice: "Tour was successfully deleted."
  end

  private

  def set_tour
    @tour = Tour.find_by!(slug: params[:slug])
  end

  def tour_params
    p = params.require(:tour).permit(
      :title, :slug, :description, :cancellation_policy, :duration, :group_size, 
      :meeting_point, :tour_type, :active, :destination_id, :image,
      :included, :excluded, :highlights, :languages,
      itinerary: [:day, :title, :desc]
    )
    
    [:included, :excluded, :highlights, :languages].each do |arr_field|
      if p[arr_field].is_a?(String)
        p[arr_field] = p[arr_field].split("\n").map(&:strip).reject(&:blank?)
      end
    end
    
    if p[:itinerary].is_a?(Array)
      p[:itinerary] = p[:itinerary].reject { |day| day[:title].blank? && day[:desc].blank? }
    end
    
    p
  end
end
