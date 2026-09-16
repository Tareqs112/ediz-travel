class Admin::DriversController < Admin::BaseController
  before_action :set_driver, only: %i[show edit update destroy]

  def index
    @drivers = Driver.includes(:todays_trip_services).order(:name)

    current_month = Date.current.beginning_of_month..Date.current.end_of_month
    @monthly_counts = TripService.where(date: current_month)
                                 .where.not(status: 'cancelled')
                                 .where.not(driver_id: nil)
                                 .group(:driver_id)
                                 .count
  end

  def show
  end

  def new
    @driver = Driver.new
  end

  def edit
  end

  def create
    @driver = Driver.new(driver_params)

    if @driver.save
      redirect_to admin_drivers_path, notice: "Driver was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @driver.update(driver_params)
      redirect_to admin_drivers_path, notice: "Driver was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @driver.destroy
      redirect_to admin_drivers_path, notice: "Driver was successfully deleted."
    else
      redirect_to admin_drivers_path, alert: @driver.errors.full_messages.to_sentence
    end
  end

  private

  def set_driver
    @driver = Driver.find(params[:id])
  end

  def driver_params
    params.require(:driver).permit(:name, :phone, :active, :notes, :is_external)
  end
end
