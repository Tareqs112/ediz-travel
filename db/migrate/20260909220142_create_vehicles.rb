class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.string :name, null: false
      t.string :vehicle_type
      t.string :plate_number, null: false
      t.string :ownership_type
      t.boolean :active, null: false, default: true
      t.text :notes

      t.timestamps
    end

    add_index :vehicles, :plate_number, unique: true
    add_index :vehicles, :active
  end
end
