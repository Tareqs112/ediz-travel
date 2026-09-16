class AddEstimatedCostToTripServices < ActiveRecord::Migration[8.1]
  def change
    add_column :trip_services, :estimated_cost, :decimal, precision: 10, scale: 2
  end
end
