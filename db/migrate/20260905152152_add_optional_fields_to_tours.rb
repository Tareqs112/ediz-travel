class AddOptionalFieldsToTours < ActiveRecord::Migration[8.1]
  def change
    add_column :tours, :highlights, :string, array: true, default: []
    add_column :tours, :meeting_point, :text
    add_column :tours, :cancellation_policy, :text
  end
end
