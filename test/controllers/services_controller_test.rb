require "test_helper"

class ServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chauffeured = CommercialVehicle.create!(name_en: "Mercedes Vito", category: "chauffeured", price_from: 80, currency: "USD", active: true)
    @self_drive = CommercialVehicle.create!(name_en: "Renault Taliant", category: "self_drive", price_from: 40, currency: "USD", active: true)
    @inactive = CommercialVehicle.create!(name_en: "Hidden Car", category: "self_drive", active: false)

    # Create an operational vehicle to ensure it doesn't bleed over
    @operational = Vehicle.create!(name: "Internal Van", plate_number: "34ABC123", active: true)
  end

  test "should get chauffeured car and show only active chauffeured vehicles" do
    get chauffeured_car_url(locale: :en)
    assert_response :success
    assert_select "h1", text: "You Travel. Your Driver Handles the Road."
    assert_select "h3", text: "Mercedes Vito"
    assert_select "h3", text: "Renault Taliant", count: 0
    assert_select "h3", text: "Hidden Car", count: 0
    assert_select "h3", text: "Internal Van", count: 0
    # Hero anchor CTA to vehicles and arrangements
    assert_select "a[href='#vehicles-and-arrangements']", minimum: 1
    # WhatsApp direct coordination CTA
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    assert_select "a[href*='text=Hello']", minimum: 1
    # Link to Car Rental service comparison
    assert_select "a[href*='car-rental']", minimum: 1
  end

  test "should get chauffeured car in Arabic with localized WhatsApp message" do
    get chauffeured_car_url(locale: :ar)
    assert_response :success
    assert_select "h1", text: "استمتع برحلتك.. ودع السائق يتولى الطريق."
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    # Verify proper URL encoded Arabic text
    assert_select "a[href*='%D9%85%D8%B1%D8%AD%D8%A8%D8%A7%D9%8B']", minimum: 1
  end

  test "should get chauffeured car in Turkish with localized WhatsApp message" do
    get chauffeured_car_url(locale: :tr)
    assert_response :success
    assert_select "h1", text: "Siz Seyahatin Tadını Çıkarın, Yolu Şoförünüz Yönetsin."
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    assert_select "a[href*='text=Merhaba']", minimum: 1
  end

  test "should get car rental and show only active self drive vehicles" do
    get car_rental_url(locale: :en)
    assert_response :success
    assert_select "h1", text: "Your Own Car for the Black Sea."
    assert_select "h3", text: "Renault Taliant"
    assert_select "h3", text: "Mercedes Vito", count: 0
    assert_select "h3", text: "Hidden Car", count: 0
    assert_select "h3", text: "Internal Van", count: 0
    # Hero anchor CTA to vehicle catalog
    assert_select "a[href='#available-vehicles']", minimum: 1
    # WhatsApp direct coordination CTA
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    assert_select "a[href*='text=Hello']", minimum: 1
    # Link to Chauffeured service comparison
    assert_select "a[href*='chauffeured-car']", minimum: 1
  end

  test "should get car rental in Arabic with localized WhatsApp message" do
    get car_rental_url(locale: :ar)
    assert_response :success
    assert_select "h1", text: "سيارتك الخاصة لاكتشاف البحر الأسود."
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    # Verify proper URL encoded Arabic text
    assert_select "a[href*='%D9%85%D8%B1%D8%AD%D8%A8%D8%A7%D9%8B']", minimum: 1
  end

  test "should get car rental in Turkish with localized WhatsApp message" do
    get car_rental_url(locale: :tr)
    assert_response :success
    assert_select "h1", text: "Karadeniz İçin Kendi Aracınız."
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    assert_select "a[href*='text=Merhaba']", minimum: 1
  end

  test "should get airport transfer with localized content and direct WhatsApp CTA" do
    get airport_transfer_url(locale: :en)
    assert_response :success
    assert_select "h1", text: "A Calm Arrival in Trabzon."
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    assert_select "a[href*='text=Hello']", minimum: 1
    # Ensure the airport transfer page body does NOT open internal plan_your_trip form for the main CTA
    assert_select "main a[href*='plan-your-trip']", count: 0
  end

  test "should get airport transfer in Arabic with localized WhatsApp message" do
    get airport_transfer_url(locale: :ar)
    assert_response :success
    assert_select "h1", text: "وصول هادئ ومريح إلى طرابزون."
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    # Verify proper URL encoded Arabic text
    assert_select "a[href*='%D9%85%D8%B1%D8%AD%D8%A8%D8%A7%D9%8B']", minimum: 1
  end

  test "should get airport transfer in Turkish with localized WhatsApp message" do
    get airport_transfer_url(locale: :tr)
    assert_response :success
    assert_select "h1", text: "Trabzon'a Huzurlu Bir Varış."
    assert_select "a[href*='wa.me/905540171890']", minimum: 2
    assert_select "a[href*='text=Merhaba']", minimum: 1
  end
end
