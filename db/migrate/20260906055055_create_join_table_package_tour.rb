class CreateJoinTablePackageTour < ActiveRecord::Migration[8.1]
  def change
    create_join_table :packages, :tours do |t|
      # t.index [:package_id, :tour_id]
      # t.index [:tour_id, :package_id]
    end
  end
end
