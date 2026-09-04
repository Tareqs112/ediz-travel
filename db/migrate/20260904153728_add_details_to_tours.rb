class AddDetailsToTours < ActiveRecord::Migration[8.1]
  def change
    add_column :tours, :duration, :string
    add_column :tours, :tour_type, :string
    add_column :tours, :group_size, :string
    add_column :tours, :languages, :string, array: true, default: []
    add_column :tours, :included, :string, array: true, default: []
    add_column :tours, :excluded, :string, array: true, default: []
    add_column :tours, :itinerary, :jsonb, default: []
  end
end
