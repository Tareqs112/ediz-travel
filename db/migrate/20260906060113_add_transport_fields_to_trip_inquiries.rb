class AddTransportFieldsToTripInquiries < ActiveRecord::Migration[8.1]
  def change
    add_column :trip_inquiries, :inquiry_type, :string, default: 'general', null: false
    add_column :trip_inquiries, :pickup_time, :string
    add_column :trip_inquiries, :pickup_location, :string
    add_column :trip_inquiries, :dropoff_location, :string
    add_column :trip_inquiries, :flight_details, :string
    add_column :trip_inquiries, :vehicle_preference, :string
  end
end
