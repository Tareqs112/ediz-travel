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

  test "should render today's services summary on index" do
    vehicle = Vehicle.create!(name: "Test Vehicle", plate_number: "61 TEST 123")
    customer = Customer.create!(name: "Jane Smith")
    booking = Booking.create!(customer: customer, source: "walk_in", status: "draft")
    
    get admin_vehicles_url
    assert_select "td", text: /None today/
    
    TripService.create!(booking: booking, service_type: "tour", date: Date.today, status: "pending", vehicle: vehicle)
    
    get admin_vehicles_url
    assert_select "td", text: /1 service/
    assert_select "a", text: /View operations/
  end

  test "should get new" do
    get new_admin_vehicle_url
    assert_response :success
  end

  test "should create vehicle" do
    assert_difference("Vehicle.count") do
      post admin_vehicles_url, params: { vehicle: { name: "New Vehicle", plate_number: "61 NEW 123", active: true } }
    end
    assert_redirected_to admin_vehicles_url(locale: nil)
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
    assert_redirected_to admin_vehicles_url(locale: nil)
    @vehicle.reload
    assert_equal "Updated Vehicle", @vehicle.name
  end

  test "should destroy vehicle" do
    assert_difference("Vehicle.count", -1) do
      delete admin_vehicle_url(@vehicle)
    end
    assert_redirected_to admin_vehicles_url(locale: nil)
  end

  test "should redirect unauthenticated user" do
    delete session_url
    get admin_vehicles_url
    assert_redirected_to new_session_url
  end
end
