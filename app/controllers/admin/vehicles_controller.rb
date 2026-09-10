class Admin::VehiclesController < Admin::BaseController
  before_action :set_vehicle, only: %i[show edit update destroy]

  def index
    @vehicles = Vehicle.order(:plate_number)
  end

  def show
  end

  def new
    @vehicle = Vehicle.new
  end

  def edit
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)

    if @vehicle.save
      redirect_to admin_vehicles_path, notice: "Vehicle was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @vehicle.update(vehicle_params)
      redirect_to admin_vehicles_path, notice: "Vehicle was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to admin_vehicles_path, notice: "Vehicle was successfully deleted."
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:name, :vehicle_type, :plate_number, :ownership_type, :active, :notes)
  end
end
