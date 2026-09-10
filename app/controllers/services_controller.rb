class ServicesController < ApplicationController
  def index
  end

  def airport_transfer
  end

  def car_rental
    @vehicles = CommercialVehicle.active.self_drive.order(price_from: :asc, name: :asc)
  end

  def chauffeured_car
    @vehicles = CommercialVehicle.active.chauffeured.order(price_from: :asc, name: :asc)
  end

  def private_tours
  end
end
