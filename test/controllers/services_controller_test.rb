require "test_helper"

class ServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chauffeured = CommercialVehicle.create!(name: "Mercedes Vito", category: "chauffeured", price_from: 80, currency: "USD", active: true)
    @self_drive = CommercialVehicle.create!(name: "Renault Taliant", category: "self_drive", price_from: 40, currency: "USD", active: true)
    @inactive = CommercialVehicle.create!(name: "Hidden Car", category: "self_drive", active: false)

    # Create an operational vehicle to ensure it doesn't bleed over
    @operational = Vehicle.create!(name: "Internal Van", plate_number: "34ABC123", active: true)
  end

  test "should get chauffeured car and show only active chauffeured vehicles" do
    get chauffeured_car_url
    assert_response :success
    assert_select "h3", text: "Mercedes Vito"
    assert_select "h3", text: "Renault Taliant", count: 0
    assert_select "h3", text: "Hidden Car", count: 0
    assert_select "h3", text: "Internal Van", count: 0
  end

  test "should get car rental and show only active self drive vehicles" do
    get car_rental_url
    assert_response :success
    assert_select "h3", text: "Renault Taliant"
    assert_select "h3", text: "Mercedes Vito", count: 0
    assert_select "h3", text: "Hidden Car", count: 0
    assert_select "h3", text: "Internal Van", count: 0
  end
end
