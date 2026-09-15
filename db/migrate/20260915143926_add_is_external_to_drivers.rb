class AddIsExternalToDrivers < ActiveRecord::Migration[8.1]
  def change
    add_column :drivers, :is_external, :boolean, default: false
  end
end
