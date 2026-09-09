class AddMetaDescriptionAndTagsToTravelGuides < ActiveRecord::Migration[8.1]
  def change
    add_column :travel_guides, :meta_description, :string
    add_column :travel_guides, :tags, :string, array: true, default: []
    add_index :travel_guides, :published_at
    add_index :travel_guides, :active
  end
end
