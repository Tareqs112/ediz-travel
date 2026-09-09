class Admin::AccommodationsController < Admin::BaseController
  before_action :set_accommodation, only: [:show, :edit, :update, :destroy]

  def index
    @accommodations = Accommodation.order(created_at: :desc)
  end

  def show
  end

  def new
    @accommodation = Accommodation.new
  end

  def create
    @accommodation = Accommodation.new(accommodation_params)
    if @accommodation.save
      redirect_to admin_accommodation_path(@accommodation), notice: "Accommodation was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @accommodation.update(accommodation_params)
      redirect_to admin_accommodation_path(@accommodation), notice: "Accommodation was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @accommodation.destroy
    redirect_to admin_accommodations_path, notice: "Accommodation was successfully deleted."
  end

  private

  def set_accommodation
    @accommodation = Accommodation.find_by!(slug: params[:slug])
  end

  def accommodation_params
    params.require(:accommodation).permit(
      :name, :slug, :description, :short_description, :location, :accommodation_type, :active, :featured, :image
    )
  end
end
