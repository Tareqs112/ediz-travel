require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in_as(users(:one))
    get admin_root_url
    assert_response :success
  end

  test "should block unauthenticated access to dashboard" do
    get admin_root_url
    assert_redirected_to new_session_url
  end

  test "should calculate today and tomorrow metrics correctly" do
    sign_in_as(users(:one))
    
    customer = Customer.create!(name: "Test Customer")
    booking = Booking.create!(customer: customer, source: "website", status: "confirmed")
    driver = Driver.create!(name: "Ali", phone: "123")
    vehicle = Vehicle.create!(name: "Vito", plate_number: "61ABC")

    # Yesterday (should be ignored)
    TripService.create!(booking: booking, service_type: "tour", date: Date.yesterday, status: "pending")

    # Today - Needs Assignment
    TripService.create!(booking: booking, service_type: "tour", date: Date.today, status: "pending")

    # Today - Fully Assigned
    TripService.create!(booking: booking, service_type: "tour", date: Date.today, status: "assigned", driver: driver, vehicle: vehicle)

    # Today - Cancelled (should be ignored in counts)
    TripService.create!(booking: booking, service_type: "tour", date: Date.today, status: "cancelled")

    # Tomorrow - Needs Assignment
    TripService.create!(booking: booking, service_type: "tour", date: Date.tomorrow, status: "pending")

    get admin_root_url
    assert_response :success

    # Today assertions
    assert_select "div", text: /Total Today/
    assert_select "div", text: "2" # 2 active, 1 cancelled

    assert_select "div", text: /Fully Assigned/
    assert_select "div.text-green-600", text: "1"

    assert_select "div", text: /Needs Driver/
    assert_select "div.text-amber-700", text: "1"

    assert_select "div", text: /Needs Vehicle/
    assert_select "div.text-amber-700", text: "1"

    assert_select "h2", text: /Needs Attention/
    assert_select "div.text-sm.font-bold", text: /Missing Driver & Vehicle/

    # Tomorrow assertions
    assert_select "h2", text: /Tomorrow's Outlook/
    assert_select "span", text: "1 services"
  end

  test "should render empty state when nothing needs attention" do
    sign_in_as(users(:one))
    
    get admin_root_url
    assert_response :success
    
    assert_select "h3", text: /Everything is ready for today/
  end
end
