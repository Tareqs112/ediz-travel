class CreateDrivers < ActiveRecord::Migration[8.1]
  def change
    create_table :drivers do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.boolean :active, null: false, default: true
      t.text :notes

      t.timestamps
    end

    add_index :drivers, :active
  end
end
