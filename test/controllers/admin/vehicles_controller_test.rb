require "test_helper"

class Admin::VehiclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }
    
    @vehicle = Vehicle.create!(name: "Test Vehicle", plate_number: "61 TEST 061", active: true)
  end

  test "should get index" do
    get admin_vehicles_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_vehicle_url
    assert_response :success
  end

  test "should create vehicle" do
    assert_difference("Vehicle.count") do
      post admin_vehicles_url, params: { vehicle: { name: "New Vehicle", plate_number: "61 NEW 123", active: true } }
    end
    assert_redirected_to admin_vehicles_url
  end

  test "should get show" do
    get admin_vehicle_url(@vehicle)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_vehicle_url(@vehicle)
    assert_response :success
  end

  test "should update vehicle" do
    patch admin_vehicle_url(@vehicle), params: { vehicle: { name: "Updated Vehicle" } }
    assert_redirected_to admin_vehicles_url
    @vehicle.reload
    assert_equal "Updated Vehicle", @vehicle.name
  end

  test "should destroy vehicle" do
    assert_difference("Vehicle.count", -1) do
      delete admin_vehicle_url(@vehicle)
    end
    assert_redirected_to admin_vehicles_url
  end

  test "should redirect unauthenticated user" do
    delete session_url
    get admin_vehicles_url
    assert_redirected_to new_session_url
  end
end
