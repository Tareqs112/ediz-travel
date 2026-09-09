class CreateTripInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :trip_inquiries do |t|
      t.string :customer_name, null: false
      t.string :email, null: false
      t.string :phone
      t.date :travel_date, null: false
      t.integer :travelers_count, null: false
      t.string :preferred_language
      t.integer :duration_days
      t.text :interests
      t.text :notes
      t.string :status, null: false, default: "new"

      t.timestamps
    end
  end
end
