class AddPriceToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :total_price, :decimal, precision: 10, scale: 2
    add_column :bookings, :currency, :string, default: "USD"
  end
end
