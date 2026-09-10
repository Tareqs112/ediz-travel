require "test_helper"

class Admin::CommercialVehiclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @vehicle = CommercialVehicle.create!(name_en: "Test Vito", category: "chauffeured", price_from: 100, currency: "USD", active: true)
  end

  test "should redirect unauthenticated user" do
    get admin_commercial_vehicles_url
    assert_redirected_to new_session_url
  end

  test "should get index for admin" do
    post session_url, params: { email_address: @admin.email_address, password: "password" }
    get admin_commercial_vehicles_url
    assert_response :success
  end

  test "should get new" do
    post session_url, params: { email_address: @admin.email_address, password: "password" }
    get new_admin_commercial_vehicle_url
    assert_response :success
  end

  test "should create commercial vehicle" do
    post session_url, params: { email_address: @admin.email_address, password: "password" }
    assert_difference("CommercialVehicle.count") do
      post admin_commercial_vehicles_url, params: {
        commercial_vehicle: {
          name_en: "New Rental",
          category: "self_drive",
          price_from: 50,
          currency: "USD"
        }
      }
    end
    assert_redirected_to admin_commercial_vehicle_url(CommercialVehicle.last)
  end

  test "should get edit" do
    post session_url, params: { email_address: @admin.email_address, password: "password" }
    get edit_admin_commercial_vehicle_url(@vehicle)
    assert_response :success
  end

  test "should update commercial vehicle" do
    post session_url, params: { email_address: @admin.email_address, password: "password" }
    patch admin_commercial_vehicle_url(@vehicle), params: {
      commercial_vehicle: { active: false }
    }
    assert_redirected_to admin_commercial_vehicle_url(@vehicle)
    @vehicle.reload
    assert_not @vehicle.active?
  end

  test "should destroy commercial vehicle" do
    post session_url, params: { email_address: @admin.email_address, password: "password" }
    assert_difference("CommercialVehicle.count", -1) do
      delete admin_commercial_vehicle_url(@vehicle)
    end
    assert_redirected_to admin_commercial_vehicles_url
  end
end
