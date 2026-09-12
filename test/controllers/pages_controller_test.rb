require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home with fallback image when hero video not attached" do
    get root_url
    assert_response :success
    assert_select "img[alt='Uzungöl, Trabzon']"
  end

  test "home page renders hero video when attached and fallback image" do
    setting = BusinessSetting.current
    blob = ActiveStorage::Blob.find_or_initialize_by(key: "test-hero.mp4")
    blob.filename = "hero.mp4"
    blob.content_type = "video/mp4"
    blob.byte_size = 4_686_396
    blob.checksum = "test-checksum"
    blob.service_name = Rails.configuration.active_storage.service.to_s
    blob.save!

    attachment = ActiveStorage::Attachment.find_or_initialize_by(
      name: "hero_video",
      record_type: "BusinessSetting",
      record_id: setting.id
    )
    attachment.blob = blob
    attachment.save!

    get root_url
    assert_response :success
    assert_select "video[autoplay][muted][loop][playsinline][preload='metadata']"
    assert_select "video[poster]", count: 0
    assert_select "video source[type='video/mp4']"

    attachment.destroy
    blob.destroy
  end

  test "should get plan_your_trip" do
    get plan_your_trip_url
    assert_response :success
  end

  test "should get airport_transfer" do
    get airport_transfer_url
    assert_response :success
  end

  test "should get private_tours" do
    get private_tours_url
    assert_response :success
  end

  test "should get packages" do
    get packages_url
    assert_response :success
  end

  test "should get about" do
    get about_url
    assert_response :success
  end

  test "should get contact" do
    get contact_url
    assert_response :success
  end

  test "should get faq" do
    get faq_url
    assert_response :success
  end
end
