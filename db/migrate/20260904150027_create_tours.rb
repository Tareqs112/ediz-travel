class CreateTours < ActiveRecord::Migration[8.1]
  def change
    create_table :tours do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.string :destination
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :tours, :slug, unique: true
    add_index :tours, :active
  end
end
