require "test_helper"

class AccommodationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hotel = accommodations(:one)
    @chalet = accommodations(:two)
  end

  test "should get index" do
    get accommodations_url
    assert_response :success
    assert_match @hotel.name, response.body
    assert_match @chalet.name, response.body
    assert_select "h1", text: "Where You Stay Shapes How You Experience the Black Sea."
    # Hero anchor CTA to stays catalog
    assert_select "a[href='#available-stays']", minimum: 1
    # WhatsApp direct coordination CTA
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    assert_select "a[href*='text=Hello']", minimum: 1
    # Internal service ecosystem links
    assert_select "a[href*='airport-transfer']", minimum: 1
    assert_select "a[href*='car-rental']", minimum: 1
    assert_select "a[href*='chauffeured-car']", minimum: 1
    assert_select "a[href*='private-tours']", minimum: 1
  end

  test "should get index with category filter" do
    get accommodations_url(type: "hotel")
    assert_response :success
    assert_match @hotel.name, response.body
    assert_no_match @chalet.name, response.body
  end

  test "should get index in Arabic with localized WhatsApp message" do
    get accommodations_url(locale: :ar)
    assert_response :success
    assert_select "h1", text: "مكان إقامتك يحدد معالم تجربتك في البحر الأسود."
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    # Verify proper URL encoded Arabic text
    assert_select "a[href*='%D9%85%D8%B1%D8%AD%D8%A8%D8%A7%D9%8B']", minimum: 1
  end

  test "should get index in Turkish with localized WhatsApp message" do
    get accommodations_url(locale: :tr)
    assert_response :success
    assert_select "h1", text: "Nerede Kaldığınız, Karadeniz Deneyiminizi Belirler."
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    assert_select "a[href*='text=Merhaba']", minimum: 1
  end

  test "should show accommodation" do
    get accommodation_url(@hotel)
    assert_response :success
    assert_match @hotel.name, response.body
  end

  test "should return 404 for inactive accommodation" do
    @hotel.update!(active: false)
    get accommodation_url(@hotel)
    assert_response :not_found
  end

  test "should return 404 for nonexistent accommodation" do
    get accommodation_url("nonexistent-slug")
    assert_response :not_found
  end
end
