class AddMobilityToModels < ActiveRecord::Migration[8.1]
  def up
    add_column :tours, :translations, :jsonb, default: {}
    add_column :commercial_vehicles, :translations, :jsonb, default: {}
    add_column :travel_guides, :translations, :jsonb, default: {}

    # Migrate data for Tours
    Tour.reset_column_information
    Tour.find_each do |tour|
      translations_data = {
        'en' => {
          'title' => tour.read_attribute(:title),
          'description' => tour.read_attribute(:description),
          'cancellation_policy' => tour.read_attribute(:cancellation_policy),
          'meeting_point' => tour.read_attribute(:meeting_point),
          'included' => tour.read_attribute(:included),
          'excluded' => tour.read_attribute(:excluded),
          'highlights' => tour.read_attribute(:highlights),
          'itinerary' => tour.read_attribute(:itinerary)
        }
      }
      tour.update_column(:translations, translations_data)
    end

    # Migrate data for CommercialVehicles
    CommercialVehicle.reset_column_information
    CommercialVehicle.find_each do |vehicle|
      translations_data = {
        'en' => {
          'name' => vehicle.read_attribute(:name),
          'description' => vehicle.read_attribute(:description)
        }
      }
      vehicle.update_column(:translations, translations_data)
    end

    # Migrate data for TravelGuides
    TravelGuide.reset_column_information
    TravelGuide.find_each do |guide|
      translations_data = {
        'en' => {
          'title' => guide.read_attribute(:title),
          'excerpt' => guide.read_attribute(:excerpt),
          'meta_description' => guide.read_attribute(:meta_description),
          'content' => guide.read_attribute(:content)
        }
      }
      guide.update_column(:translations, translations_data)
    end
  end

  def down
    remove_column :tours, :translations
    remove_column :commercial_vehicles, :translations
    remove_column :travel_guides, :translations
  end
end
