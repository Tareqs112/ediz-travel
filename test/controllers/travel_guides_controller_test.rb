require "test_helper"

class TravelGuidesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @guide = travel_guides(:one)
  end

  test "should get index and exclude draft articles" do
    get travel_guides_url
    assert_response :success
    assert_match @guide.title, response.body
    assert_no_match travel_guides(:draft_guide).title, response.body
  end

  test "should show active travel guide" do
    get travel_guide_url(@guide.slug)
    assert_response :success
    assert_match @guide.title, response.body
    assert_select 'meta[name="description"]' do |elements|
      assert_match "Explore Trabzon guide", elements.first["content"]
    end
  end

  test "should return 404 for inactive travel guide" do
    @guide.update!(active: false)
    get travel_guide_url(@guide.slug)
    assert_response :not_found
  end

  test "should return 404 for draft travel guide" do
    draft = travel_guides(:draft_guide)
    get travel_guide_url(draft.slug)
    assert_response :not_found
  end

  test "should return 404 for future published travel guide" do
    @guide.update!(published_at: 1.day.from_now)
    get travel_guide_url(@guide.slug)
    assert_response :not_found
  end

  test "should return 404 for non-existent travel guide" do
    get travel_guide_url("totally-unknown-slug")
    assert_response :not_found
  end
end
