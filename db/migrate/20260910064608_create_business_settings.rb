class CreateBusinessSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :business_settings do |t|
      t.string :company_name
      t.string :whatsapp_number
      t.string :contact_email
      t.string :address
      t.string :tursab_number
      t.string :google_maps_url
      t.text :booking_policies

      t.boolean :singleton_guard, null: false, default: true

      t.timestamps
    end

    add_index :business_settings, :singleton_guard, unique: true
  end
end
