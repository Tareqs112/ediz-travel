class Admin::PackagesController < Admin::BaseController
  before_action :set_package, only: [:show, :edit, :update, :destroy]

  def index
    @packages = Package.order(created_at: :desc)
  end

  def show
  end

  def new
    @package = Package.new
  end

  def create
    @package = Package.new(package_params)
    if @package.save
      redirect_to admin_package_path(@package), notice: "Package was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @package.update(package_params)
      redirect_to admin_package_path(@package), notice: "Package was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @package.destroy
    redirect_to admin_packages_path, notice: "Package was successfully deleted."
  end

  private

  def set_package
    @package = Package.find_by!(slug: params[:slug])
  end

  def package_params
    p = params.require(:package).permit(
      :title, :slug, :description, :short_description, :duration, :active, :image,
      :included, :excluded, :highlights,
      itinerary: [:day, :title, :desc],
      tour_ids: [], destination_ids: [], accommodation_ids: []
    )
    
    [:included, :excluded, :highlights].each do |arr_field|
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
