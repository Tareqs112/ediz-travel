class AddCommercialFieldsToTours < ActiveRecord::Migration[8.1]
  def change
    add_column :tours, :price_from, :decimal, precision: 10, scale: 2
    add_column :tours, :currency, :string
    add_column :tours, :featured, :boolean, default: false, null: false
    
    add_index :tours, :featured
  end
end
