class CreateDestinations < ActiveRecord::Migration[8.1]
  def change
    create_table :destinations do |t|
      t.string :name
      t.string :slug
      t.text :short_description
      t.text :description
      t.string :region
      t.string :best_time_to_visit
      t.boolean :active

      t.timestamps
    end
    add_index :destinations, :slug, unique: true
  end
end
