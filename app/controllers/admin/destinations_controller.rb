class Admin::DestinationsController < Admin::BaseController
  before_action :set_destination, only: [:show, :edit, :update, :destroy]

  def index
    @destinations = Destination.order(created_at: :desc)
  end

  def show
  end

  def new
    @destination = Destination.new
  end

  def create
    @destination = Destination.new(destination_params)
    if @destination.save
      redirect_to admin_destination_path(@destination), notice: "Destination was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @destination.update(destination_params)
      redirect_to admin_destination_path(@destination), notice: "Destination was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @destination.destroy
    redirect_to admin_destinations_path, notice: "Destination was successfully deleted."
  end

  private

  def set_destination
    @destination = Destination.find_by!(slug: params[:slug])
  end

  def destination_params
    params.require(:destination).permit(
      :name, :slug, :description, :short_description, :region, :best_time_to_visit, :active, :image
    )
  end
end
