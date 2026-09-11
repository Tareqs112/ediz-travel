require "test_helper"

class DriverTest < ActiveSupport::TestCase
  test "should save valid driver" do
    driver = Driver.new(name: "Ahmet Yilmaz", phone: "+905551234567")
    assert driver.save
    assert driver.active
  end

  test "should not save driver without name" do
    driver = Driver.new(phone: "+905551234567")
    assert_not driver.save
  end

  test "should not save driver without phone" do
    driver = Driver.new(name: "Ahmet Yilmaz")
    assert_not driver.save
  end

  test "should not delete driver with historical services" do
    driver = Driver.create!(name: "Test Driver", phone: "123")
    customer = Customer.create!(name: "Jane Smith")
    booking = Booking.create!(customer: customer, source: "walk_in", status: "draft")
    TripService.create!(booking: booking, service_type: "tour", date: Date.today, status: "pending", driver: driver)
    
    assert_not driver.destroy
    assert_includes driver.errors[:base], "Cannot delete record because dependent trip services exist"
  end
end
