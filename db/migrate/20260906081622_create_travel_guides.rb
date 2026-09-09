class CreateTravelGuides < ActiveRecord::Migration[8.1]
  def change
    create_table :travel_guides do |t|
      t.string :title
      t.string :slug
      t.text :excerpt
      t.text :content
      t.boolean :active
      t.datetime :published_at

      t.timestamps
    end
    add_index :travel_guides, :slug, unique: true
  end
end
