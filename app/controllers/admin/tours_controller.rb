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
    if @tour.destroy
      redirect_to admin_tours_path, notice: "Tour was successfully deleted."
    else
      error_message = @tour.errors.full_messages.to_sentence.presence || "Cannot delete tour because it has dependent records."
      redirect_to admin_tour_path(@tour), alert: error_message
    end
  end

  private

  def set_tour
    @tour = Tour.find_by!(slug: params[:slug])
  end

  def tour_params
  permit_args = [
    :slug, :duration, :group_size, :tour_type, :active, :destination_id, :image,
    :price_from, :currency, :featured
  ]

  [:en, :ar, :tr].each do |l|
    permit_args += [
      :"title_#{l}", :"description_#{l}", :"cancellation_policy_#{l}",
      :"meeting_point_#{l}", :"included_#{l}", :"excluded_#{l}",
      :"highlights_#{l}", { :"itinerary_#{l}" => [:day, :title, :desc] }
    ]
  end
  # languages remains untranslated
  permit_args << :languages

  p = params.require(:tour).permit(*permit_args)

  [:en, :ar, :tr].each do |l|
    [:"included_#{l}", :"excluded_#{l}", :"highlights_#{l}"].each do |arr_field|
      if p[arr_field].is_a?(String)
        p[arr_field] = p[arr_field].split("\n").map(&:strip).reject(&:blank?)
      end
    end

    it_field = :"itinerary_#{l}"
    if p[it_field].is_a?(Array)
      p[it_field] = p[it_field].reject { |day| day[:title].blank? && day[:desc].blank? }
    end
  end

  if p[:languages].is_a?(String)
    p[:languages] = p[:languages].split("\n").map(&:strip).reject(&:blank?)
  end

  p
end
end
