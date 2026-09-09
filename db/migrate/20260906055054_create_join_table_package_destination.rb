class CreateJoinTablePackageDestination < ActiveRecord::Migration[8.1]
  def change
    create_join_table :packages, :destinations do |t|
      # t.index [:package_id, :destination_id]
      # t.index [:destination_id, :package_id]
    end
  end
end
