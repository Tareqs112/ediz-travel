require "test_helper"

class Admin::BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    @customer = Customer.create!(name: "Jane Smith")
    @booking = Booking.create!(customer: @customer, source: "walk_in", status: "draft")
  end

  test "should get index" do
    get admin_bookings_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_booking_url
    assert_response :success
  end

  test "should create booking" do
    assert_difference("Booking.count") do
      post admin_bookings_url, params: { booking: { customer_id: @customer.id, source: "phone", status: "confirmed" } }
    end
    assert_redirected_to admin_booking_url(Booking.last)
  end

  test "should get show" do
    get admin_booking_url(@booking)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_booking_url(@booking)
    assert_response :success
  end

  test "should update booking" do
    patch admin_booking_url(@booking), params: { booking: { status: "active" } }
    assert_redirected_to admin_booking_url(@booking)
    @booking.reload
    assert_equal "active", @booking.status
  end

  test "should destroy booking" do
    assert_difference("Booking.count", -1) do
      delete admin_booking_url(@booking)
    end
    assert_redirected_to admin_bookings_url
  end

  test "should redirect unauthenticated user" do
    delete session_url
    get admin_bookings_url
    assert_redirected_to new_session_url
  end
end
