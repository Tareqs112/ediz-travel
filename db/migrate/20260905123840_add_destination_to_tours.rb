class AddDestinationToTours < ActiveRecord::Migration[8.1]
  def up
    rename_column :tours, :destination, :old_destination_name
    add_reference :tours, :destination, foreign_key: true, null: true

    Tour.reset_column_information
    Destination.reset_column_information

    Tour.find_each do |tour|
      if tour.old_destination_name.present?
        # Destination names are like "Çaykara, Trabzon". We want to keep it or just take the first part?
        # The prompt says: "Trabzon, Uzungöl, Sümela Monastery, Ayder Plateau" for seeds.
        # But the old destinations in DB are: "Çaykara, Trabzon" (Uzungöl), "Maçka, Trabzon" (Sümela), "Çamlıhemşin, Rize" (Ayder).
        # Wait, the prompt says "Update db/seeds.rb with only the existing development destinations: Trabzon, Uzungöl, Sümela Monastery, Ayder Plateau"
        # Let's map them explicitly.
        
        dest_name = case tour.old_destination_name
                    when "Çaykara, Trabzon" then "Uzungöl"
                    when "Maçka, Trabzon" then "Sümela Monastery"
                    when "Çamlıhemşin, Rize" then "Ayder Plateau"
                    else "Trabzon"
                    end
                    
        dest = Destination.find_or_create_by!(name: dest_name) do |d|
          d.slug = dest_name.parameterize
          d.active = true
        end
        tour.update_columns(destination_id: dest.id)
      end
    end

    remove_column :tours, :old_destination_name, :string
  end

  def down
    add_column :tours, :old_destination_name, :string

    Tour.reset_column_information
    
    Tour.find_each do |tour|
      if tour.destination_id
        dest = Destination.find_by(id: tour.destination_id)
        if dest
          tour.update_columns(old_destination_name: dest.name)
        end
      end
    end

    remove_reference :tours, :destination, foreign_key: true
    rename_column :tours, :old_destination_name, :destination
  end
end
