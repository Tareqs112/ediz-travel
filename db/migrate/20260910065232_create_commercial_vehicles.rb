class CreateCommercialVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :commercial_vehicles do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.integer :passenger_capacity
      t.integer :luggage_capacity
      t.decimal :price_from, precision: 10, scale: 2
      t.string :currency
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :commercial_vehicles, :category
    add_index :commercial_vehicles, :active
  end
end
