class CreatePackages < ActiveRecord::Migration[8.1]
  def change
    create_table :packages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.text :short_description
      t.string :duration
      t.boolean :active, default: true, null: false
      t.jsonb :itinerary, default: []
      t.string :included, array: true, default: []
      t.string :excluded, array: true, default: []
      t.string :highlights, array: true, default: []

      t.timestamps
    end
    add_index :packages, :slug, unique: true
  end
end
