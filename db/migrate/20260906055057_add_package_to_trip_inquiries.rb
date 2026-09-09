class AddPackageToTripInquiries < ActiveRecord::Migration[8.1]
  def change
    add_reference :trip_inquiries, :package, null: true, foreign_key: true
  end
end
