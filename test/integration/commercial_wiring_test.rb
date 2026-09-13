require "test_helper"

class CommercialWiringTest < ActionDispatch::IntegrationTest
  setup do
    BusinessSetting.destroy_all
    @setting = BusinessSetting.create!(
      company_name: "TEST COMPANY L.L.C.",
      whatsapp_number: "+905551234567",
      contact_email: "hello@testcompany.com",
      tursab_number: "9999",
      address: "123 Test St",
      google_maps_url: "https://maps.google.com/?q=test"
    )
    Rails.cache.clear
  end

  test "public pages use the stored business setting values" do
    get contact_path
    assert_response :success
    assert_select "p", text: /TEST COMPANY L.L\.C\./
    assert_select "p", text: /9999/
    assert_select "p", text: /\+905551234567/
    assert_select "p", text: /hello@testcompany.com/
    
    get root_path
    assert_response :success
    assert_select "footer", text: /TEST COMPANY L.L\.C\./
    assert_select "footer", text: /9999/
  end

  test "blank optional values are handled gracefully" do
    @setting.update!(whatsapp_number: "", contact_email: "", google_maps_url: "")
    Rails.cache.clear
    
    get contact_path
    assert_response :success
    assert_select "p", text: /Direct Contact/, count: 0
    assert_select "a[href*='wa.me']", count: 0
  end

  test "whatsapp floating button is generated correctly from BusinessSetting" do
    get root_path
    assert_response :success
    assert_select "a[href='https://wa.me/905551234567']"
    
    @setting.update!(whatsapp_number: "")
    Rails.cache.clear
    get root_path
    assert_response :success
    assert_select "a[href*='wa.me']", count: 0
  end
end

class TourCommercialTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email_address: "admin@ediztravel.com", password: "password", password_confirmation: "password")
    
    @tour = Tour.create!(
      title_en: "Test Tour",
      description_en: "Test desc",
      slug: "test-tour",
      active: true,
      price_from: 100.50,
      currency: "USD",
      featured: true
    )
    
    BusinessSetting.create!(company_name: "Test")
    Rails.cache.clear
  end

  test "price_from, currency, and featured persist correctly" do
    assert_equal 100.50, @tour.price_from
    assert_equal "USD", @tour.currency
    assert @tour.featured
  end

  test "public tour card and detail display price when present" do
    get tours_path
    assert_response :success
    assert_match /USD 101/, response.body
    
    get tour_path(@tour)
    assert_response :success
    assert_match /USD 101/, response.body
  end

  test "public tour card and detail hide price when not present" do
    @tour.update!(price_from: nil)
    
    get tours_path
    assert_response :success
    assert_no_match /USD 101/, response.body
    
    get tour_path(@tour)
    assert_response :success
    assert_no_match /USD 101/, response.body
  end

  test "admin can update tour commercial fields" do
    post session_path, params: { email_address: @admin.email_address, password: "password" }
    
    patch admin_tour_path(@tour), params: {
      tour: {
        price_from: 250.00,
        currency: "EUR",
        featured: "0"
      }
    }
    
    assert_redirected_to admin_tour_path(@tour, locale: nil)
    @tour.reload
    assert_equal 250.00, @tour.price_from
    assert_equal "EUR", @tour.currency
    assert_not @tour.featured
  end
end
