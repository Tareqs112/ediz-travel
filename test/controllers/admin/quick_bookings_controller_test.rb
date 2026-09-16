require "test_helper"

class Admin::QuickBookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }
  end

  test "should get new" do
    get new_admin_quick_booking_url
    assert_response :success
    assert_select "form"
  end

  test "should create quick booking and redirect to booking show page" do
    assert_difference("Customer.count", 1) do
      assert_difference("Booking.count", 1) do
        assert_difference("TripService.count", 1) do
          post admin_quick_bookings_url, params: {
            quick_booking_form: {
              customer_name: "Jane Quick",
              customer_phone: "+90 555 999 8888",
              source: "whatsapp",
              status: "confirmed",
              total_price: "200",
              currency: "USD",
              service_type: "tour",
              service_date: "2026-11-01"
            }
          }
        end
      end
    end

    booking = Booking.last
    assert_redirected_to admin_booking_url(booking, locale: nil)
    assert_equal "Jane Quick", booking.customer.name
    assert_equal "whatsapp", booking.source
    assert_equal "USD", booking.currency
    assert_equal 200.0, booking.total_price
  end
  
  test "should re-render new with errors if invalid" do
    post admin_quick_bookings_url, params: {
      quick_booking_form: {
        customer_name: "", # invalid
        customer_phone: "+90 555 999 8888",
        source: "whatsapp",
        status: "confirmed",
        service_type: "tour",
        service_date: "2026-11-01"
      }
    }
    
    assert_response :unprocessable_entity
    assert_select "form"
    assert_select ".bg-red-50", text: /Customer name can't be blank/
  end

  test "should display external driver badge in dropdown" do
    Driver.create!(name: "Internal Bob", phone: "111", active: true, is_external: false)
    Driver.create!(name: "External Alice", phone: "222", active: true, is_external: true)

    get new_admin_quick_booking_url
    assert_response :success

    # Unassigned option
    assert_select "select#quick_booking_form_driver_id option", text: "Unassigned"
    # Internal driver is plain name
    assert_select "select#quick_booking_form_driver_id option", text: "Internal Bob"
    # External driver has badge
    assert_select "select#quick_booking_form_driver_id option", text: "External Alice (External)"
  end
end
