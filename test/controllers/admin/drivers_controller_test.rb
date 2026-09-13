require "test_helper"

class Admin::DriversControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }
    
    @driver = Driver.create!(name: "Test Driver", phone: "+905550000000", active: true)
  end

  test "should get index" do
    get admin_drivers_url
    assert_response :success
  end

  test "should render today's services summary on index" do
    driver = Driver.create!(name: "Test Driver", phone: "123")
    customer = Customer.create!(name: "Jane Smith")
    booking = Booking.create!(customer: customer, source: "walk_in", status: "draft")
    
    get admin_drivers_url
    assert_select "td", text: /None today/
    
    TripService.create!(booking: booking, service_type: "tour", date: Date.today, status: "pending", driver: driver)
    
    get admin_drivers_url
    assert_select "td", text: /1 service/
    assert_select "a", text: /View operations/
  end

  test "should get new" do
    get new_admin_driver_url
    assert_response :success
  end

  test "should create driver" do
    assert_difference("Driver.count") do
      post admin_drivers_url, params: { driver: { name: "New Driver", phone: "12345", active: true } }
    end
    assert_redirected_to admin_drivers_url(locale: nil)
  end

  test "should get show" do
    get admin_driver_url(@driver)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_driver_url(@driver)
    assert_response :success
  end

  test "should update driver" do
    patch admin_driver_url(@driver), params: { driver: { name: "Updated Driver" } }
    assert_redirected_to admin_drivers_url(locale: nil)
    @driver.reload
    assert_equal "Updated Driver", @driver.name
  end

  test "should destroy driver" do
    assert_difference("Driver.count", -1) do
      delete admin_driver_url(@driver)
    end
    assert_redirected_to admin_drivers_url(locale: nil)
  end

  test "should redirect unauthenticated user" do
    delete session_url
    get admin_drivers_url
    assert_redirected_to new_session_url
  end
end
