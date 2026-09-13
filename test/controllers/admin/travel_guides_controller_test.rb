require "test_helper"

class Admin::TravelGuidesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @guide = travel_guides(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }
  end

  test "should get index" do
    get admin_travel_guides_url
    assert_response :success
  end

  test "should filter index by status" do
    get admin_travel_guides_url(status: "published")
    assert_response :success
    assert_select "td", text: /Guide 1/

    get admin_travel_guides_url(status: "draft")
    assert_response :success
    assert_select "td", text: /Draft Guide/
  end

  test "should get new" do
    get new_admin_travel_guide_url
    assert_response :success
  end

  test "should create travel guide as draft" do
    assert_difference("TravelGuide.count") do
      post admin_travel_guides_url, params: {
        publication_action: "save_draft",
        travel_guide: {
          title_en: "New Draft Guide",
          excerpt_en: "Draft excerpt",
          content_en: "<p>Draft body</p>",
          tag_list: "Trabzon, Tips",
          meta_description_en: "Draft meta"
        }
      }
    end
    assert_redirected_to admin_travel_guides_url(locale: nil)
    guide = TravelGuide.find_by(slug: "new-draft-guide")
    assert_not guide.published?
    assert guide.draft?
    assert_equal ["Trabzon", "Tips"], guide.tags
  end

  test "should create travel guide as published" do
    assert_difference("TravelGuide.count") do
      post admin_travel_guides_url, params: {
        publication_action: "publish",
        travel_guide: {
          title_en: "New Published Guide",
          excerpt_en: "Published excerpt",
          content_en: "<p>Published body</p>",
          tag_list: "Rize, Ayder"
        }
      }
    end
    assert_redirected_to admin_travel_guides_url(locale: nil)
    guide = TravelGuide.find_by(slug: "new-published-guide")
    assert guide.published?
  end

  test "should show travel guide" do
    get admin_travel_guide_url(@guide)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_travel_guide_url(@guide, locale: nil)
    assert_response :success
  end

  test "should update travel guide" do
    patch admin_travel_guide_url(@guide), params: {
      publication_action: "publish",
      travel_guide: { title_en: "Updated Title", tag_list: "UpdatedTag" }
    }
    assert_redirected_to admin_travel_guides_url(locale: nil)
    @guide.reload
    assert_equal "Updated Title", @guide.title
    assert_equal ["UpdatedTag"], @guide.tags
  end

  test "should preview travel guide" do
    get preview_admin_travel_guide_url(@guide)
    assert_response :success
    assert_match "Admin Preview Mode", response.body
    assert_match @guide.title, response.body
  end

  test "should publish travel guide" do
    draft = travel_guides(:draft_guide)
    assert draft.draft?

    patch publish_admin_travel_guide_url(draft)
    assert_redirected_to admin_travel_guides_url(locale: nil)
    draft.reload
    assert draft.published?
  end

  test "should unpublish travel guide" do
    assert @guide.published?

    patch unpublish_admin_travel_guide_url(@guide)
    assert_redirected_to admin_travel_guides_url(locale: nil)
    @guide.reload
    assert @guide.draft?
  end

  test "should upload image via upload_image endpoint" do
    file = fixture_file_upload("test/fixtures/files/test_image.jpg", "image/jpeg") rescue nil
    # Test upload with mock file or StringIO if fixture file is not on disk
    post upload_image_admin_travel_guides_url, params: {
      file: Rack::Test::UploadedFile.new(
        StringIO.new("fake image data"),
        "image/jpeg",
        original_filename: "test.jpg"
      )
    }
    assert_response :success
    json = JSON.parse(response.body)
    assert json["url"].present?
    assert_equal "test.jpg", json["filename"]
  end

  test "should remove attached body image" do
    @guide.body_images.attach(
      io: StringIO.new("fake image data"),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )
    attachment = @guide.body_images.last
    assert_difference("@guide.body_images.count", -1) do
      delete remove_body_image_admin_travel_guide_url(@guide, image_id: attachment.id)
    end
    assert_redirected_to edit_admin_travel_guide_url(@guide, locale: nil)
  end

  test "should destroy travel guide" do
    assert_difference("TravelGuide.count", -1) do
      delete admin_travel_guide_url(@guide)
    end
    assert_redirected_to admin_travel_guides_url(locale: nil)
  end

  test "requires authentication for admin actions" do
    delete session_url # logout
    get admin_travel_guides_url
    assert_redirected_to new_session_url

    get preview_admin_travel_guide_url(@guide)
    assert_redirected_to new_session_url
  end
end
