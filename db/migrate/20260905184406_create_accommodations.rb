class CreateAccommodations < ActiveRecord::Migration[8.1]
  def change
    create_table :accommodations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :accommodation_type, null: false
      t.text :short_description
      t.text :description
      t.string :location
      t.boolean :active, default: true, null: false
      t.boolean :featured, default: false, null: false

      t.timestamps
    end
    add_index :accommodations, :slug, unique: true
    add_index :accommodations, :accommodation_type
    add_index :accommodations, :active
  end
end
