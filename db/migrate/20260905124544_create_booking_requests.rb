class CreateBookingRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_requests do |t|
      t.string :customer_name, null: false
      t.string :email, null: false
      t.string :phone
      t.date :travel_date, null: false
      t.integer :travelers_count, null: false
      t.string :preferred_language
      t.text :notes
      t.string :status, null: false, default: "new"
      t.references :tour, null: false, foreign_key: true

      t.timestamps
    end
  end
end
