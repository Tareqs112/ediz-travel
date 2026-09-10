class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :booking_request, null: true, foreign_key: true
      t.references :trip_inquiry, null: true, foreign_key: true
      t.string :source, null: false, default: "other"
      t.string :status, null: false, default: "draft"
      t.date :start_date
      t.date :end_date
      t.text :notes

      t.timestamps
    end

    add_index :bookings, :status
    add_index :bookings, :source
  end
end
