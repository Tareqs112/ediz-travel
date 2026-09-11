class CreateTripServices < ActiveRecord::Migration[8.1]
  def change
    create_table :trip_services do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :driver, null: true, foreign_key: true
      t.references :vehicle, null: true, foreign_key: true
      t.string :service_type, null: false
      t.date :date, null: false
      t.time :start_time
      t.time :end_time
      t.string :pickup_location
      t.string :dropoff_location
      t.string :status, null: false, default: "pending"
      t.text :notes

      t.timestamps
    end
    
    add_index :trip_services, :date
    add_index :trip_services, :status
    add_index :trip_services, :service_type
  end
end
