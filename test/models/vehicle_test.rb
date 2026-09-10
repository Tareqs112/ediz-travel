require "test_helper"

class VehicleTest < ActiveSupport::TestCase
  test "should save valid vehicle" do
    vehicle = Vehicle.new(name: "VIP Vito 1", plate_number: "61 EDZ 061")
    assert vehicle.save
    assert vehicle.active
  end

  test "should not save vehicle without name" do
    vehicle = Vehicle.new(plate_number: "61 EDZ 061")
    assert_not vehicle.save
  end

  test "should not save vehicle without plate_number" do
    vehicle = Vehicle.new(name: "VIP Vito 1")
    assert_not vehicle.save
  end

  test "should not save vehicle with duplicate plate_number" do
    Vehicle.create!(name: "VIP Vito 1", plate_number: "61 EDZ 061")
    vehicle2 = Vehicle.new(name: "VIP Vito 2", plate_number: "61 EDZ 061")
    assert_not vehicle2.save
  end
end
