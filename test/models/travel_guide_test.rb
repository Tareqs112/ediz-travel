require "test_helper"

class TravelGuideTest < ActiveSupport::TestCase
  test "requires title" do
    guide = TravelGuide.new(slug: "test")
    assert_not guide.valid?
    assert_includes guide.errors[:title], "can't be blank"
  end

  test "requires unique slug" do
    existing = travel_guides(:one)
    guide = TravelGuide.new(title: "Another", slug: existing.slug)
    assert_not guide.valid?
    assert_includes guide.errors[:slug], "has already been taken"
  end

  test "auto-generates slug from title if missing" do
    guide = TravelGuide.new(title: "My Awesome Guide")
    guide.valid?
    assert_equal "my-awesome-guide", guide.slug
  end

  test "keeps provided slug" do
    guide = TravelGuide.new(title: "My Awesome Guide", slug: "custom-slug")
    guide.valid?
    assert_equal "custom-slug", guide.slug
  end

  test "published scope returns only active guides with past or present published_at" do
    published_guides = TravelGuide.published
    assert_includes published_guides, travel_guides(:one)
    assert_not_includes published_guides, travel_guides(:draft_guide)
  end

  test "draft scope returns inactive or future published guides" do
    draft_guides = TravelGuide.draft
    assert_includes draft_guides, travel_guides(:draft_guide)
    assert_not_includes draft_guides, travel_guides(:one)
  end

  test "status returns published or draft" do
    assert_equal "published", travel_guides(:one).status
    assert_equal "draft", travel_guides(:draft_guide).status
  end

  test "publish! and unpublish! actions" do
    guide = travel_guides(:draft_guide)
    guide.title = "A title" # Ensure title is present in case fixture has issues
    assert guide.draft?

    guide.publish!
    assert guide.published?
    assert guide.active?
    assert guide.published_at.present?

    guide.unpublish!
    assert guide.draft?
    assert_not guide.active?
  end

  test "handles tags array conversion" do
    guide = TravelGuide.new
    guide.tag_list = "Trabzon, Food, Nature"

    assert_equal ["Trabzon", "Food", "Nature"], guide.tags
    assert_equal "Trabzon, Food, Nature", guide.tag_list
  end

  test "estimated reading time" do
    guide1 = TravelGuide.new(content: "word " * 400)
    assert_equal 2, guide1.estimated_reading_time

    guide2 = TravelGuide.new(content: "word " * 100)
    assert_equal 1, guide2.estimated_reading_time
  end

  test "sanitizes content and removes dangerous tags" do
    guide = TravelGuide.new(content: "<script>alert('xss')</script><p>Safe content</p> <a href='javascript:alert(1)'>Link</a>")
    sanitized = guide.sanitized_content

    assert_not_includes sanitized, "<script>"
    assert_includes sanitized, "<p>Safe content</p>"
    assert_not_includes sanitized, "javascript:"
  end

  test "meta_description_or_fallback falls back to excerpt and title" do
    guide = TravelGuide.new(title: "Guide Title", excerpt: "Short summary", meta_description: "")
    assert_equal "Short summary", guide.meta_description_or_fallback

    guide2 = TravelGuide.new(title: "Guide Title", excerpt: "", meta_description: "")
    assert_equal "Guide Title", guide2.meta_description_or_fallback

    guide3 = TravelGuide.new(title: "Guide Title", excerpt: "Short summary", meta_description: "Explicit SEO snippet")
    assert_equal "Explicit SEO snippet", guide3.meta_description_or_fallback
  end
end
