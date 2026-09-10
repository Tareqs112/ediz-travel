class Admin::CommercialVehiclesController < Admin::BaseController
  before_action :set_commercial_vehicle, only: [:show, :edit, :update, :destroy]

  def index
    @commercial_vehicles = CommercialVehicle.order(category: :asc, name: :asc)
  end

  def show
  end

  def new
    @commercial_vehicle = CommercialVehicle.new(category: 'chauffeured', currency: 'USD')
  end

  def create
    @commercial_vehicle = CommercialVehicle.new(commercial_vehicle_params)

    if @commercial_vehicle.save
      redirect_to admin_commercial_vehicle_path(@commercial_vehicle), notice: "Commercial vehicle was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @commercial_vehicle.update(commercial_vehicle_params)
      redirect_to admin_commercial_vehicle_path(@commercial_vehicle), notice: "Commercial vehicle was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @commercial_vehicle.destroy
    redirect_to admin_commercial_vehicles_path, notice: "Commercial vehicle was successfully deleted."
  end

  private

  def set_commercial_vehicle
    @commercial_vehicle = CommercialVehicle.find(params[:id])
  end

  def commercial_vehicle_params
  permit_args = [:category, :passenger_capacity, :luggage_capacity, :price_from, :currency, :active, :image]
  [:en, :ar, :tr].each do |loc|
    permit_args += [:"name_#{loc}", :"description_#{loc}"]
  end
  params.require(:commercial_vehicle).permit(*permit_args)
end
end
