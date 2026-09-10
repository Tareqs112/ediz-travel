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
end
