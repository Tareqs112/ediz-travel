require "test_helper"

class CommercialVehicleTest < ActiveSupport::TestCase
  test "requires name" do
    vehicle = CommercialVehicle.new(category: "chauffeured")
    assert_not vehicle.valid?
    assert_includes vehicle.errors[:name], "can't be blank"
  end

  test "requires valid category" do
    vehicle = CommercialVehicle.new(name: "Test Vehicle", category: "invalid")
    assert_not vehicle.valid?

    vehicle.category = "chauffeured"
    assert vehicle.valid?

    vehicle.category = "self_drive"
    assert vehicle.valid?
  end

  test "validates price is positive" do
    vehicle = CommercialVehicle.new(name: "Test", category: "chauffeured", price_from: -10)
    assert_not vehicle.valid?

    vehicle.price_from = 0
    assert vehicle.valid?
  end

  test "active scope returns only active vehicles" do
    CommercialVehicle.create!(name: "Active 1", category: "chauffeured", active: true)
    CommercialVehicle.create!(name: "Inactive 1", category: "chauffeured", active: false)

    active_vehicles = CommercialVehicle.active
    assert_equal 1, active_vehicles.count
    assert_equal "Active 1", active_vehicles.first.name
  end
end
