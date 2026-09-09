class AddAccommodationToTripInquiries < ActiveRecord::Migration[8.1]
  def change
    add_reference :trip_inquiries, :accommodation, null: true, foreign_key: true
  end
end
