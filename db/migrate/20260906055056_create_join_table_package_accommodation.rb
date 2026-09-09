class CreateJoinTablePackageAccommodation < ActiveRecord::Migration[8.1]
  def change
    create_join_table :packages, :accommodations do |t|
      # t.index [:package_id, :accommodation_id]
      # t.index [:accommodation_id, :package_id]
    end
  end
end
