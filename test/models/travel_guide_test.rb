require "test_helper"

class TravelGuideTest < ActiveSupport::TestCase
  test "requires title" do
    guide = TravelGuide.new(title: "")
    assert_not guide.valid?
    assert_includes guide.errors[:title], "can't be blank"
  end

  test "auto generates slug from title" do
    guide = TravelGuide.create!(title: "Comprehensive Guide to Trabzon")
    assert_equal "comprehensive-guide-to-trabzon", guide.slug
  end

  test "avoids duplicate slug by appending counter" do
    guide1 = TravelGuide.create!(title: "Unique Guide Title")
    guide2 = TravelGuide.create!(title: "Unique Guide Title")
    assert_equal "unique-guide-title", guide1.slug
    assert_equal "unique-guide-title-1", guide2.slug
  end

  test "allows manual slug customization" do
    guide = TravelGuide.create!(title: "Custom Title", slug: "my-custom-slug")
    assert_equal "my-custom-slug", guide.slug
  end

  test "published and draft scopes work correctly" do
    published = travel_guides(:one)
    draft = travel_guides(:draft_guide)

    assert_includes TravelGuide.published, published
    assert_not_includes TravelGuide.published, draft

    assert_includes TravelGuide.draft, draft
    assert_not_includes TravelGuide.draft, published
  end

  test "published? and draft? logic" do
    published = travel_guides(:one)
    draft = travel_guides(:draft_guide)

    assert published.published?
    assert_not published.draft?

    assert draft.draft?
    assert_not draft.published?
  end

  test "publish! and unpublish! actions" do
    guide = travel_guides(:draft_guide)
    assert guide.draft?

    guide.publish!
    assert guide.published?
    assert guide.active?
    assert guide.published_at.present?

    guide.unpublish!
    assert guide.draft?
    assert_not guide.active?
  end

  test "tag_list getter and setter" do
    guide = TravelGuide.new(title: "Tagged Guide")
    guide.tag_list = "Trabzon, Black Sea, Nature"
    assert_equal ["Trabzon", "Black Sea", "Nature"], guide.tags
    assert_equal "Trabzon, Black Sea, Nature", guide.tag_list
  end

  test "sanitized_content removes dangerous scripts and styles but keeps safe markup" do
    guide = TravelGuide.new(
      title: "Security Test",
      content: '<h2>Safe Heading</h2><p>Safe text with <script>alert("XSS")</script> and <a href="https://example.com" onclick="steal()">link</a>.</p><figure><img src="https://example.com/img.jpg" alt="test" style="color:red" /></figure>'
    )
    sanitized = guide.sanitized_content

    assert_includes sanitized, "<h2>Safe Heading</h2>"
    assert_includes sanitized, '<a href="https://example.com">link</a>'
    assert_includes sanitized, '<img src="https://example.com/img.jpg" alt="test"'
    assert_no_match(/<script>/, sanitized)
    assert_no_match(/alert/, sanitized)
    assert_no_match(/onclick/, sanitized)
    assert_no_match(/style=/, sanitized)
  end

  test "meta_description_or_fallback falls back to excerpt and title" do
    guide = TravelGuide.new(title: "Guide Title", excerpt: "Short summary", meta_description: "")
    assert_equal "Short summary", guide.meta_description_or_fallback

    guide.excerpt = ""
    assert_equal "Guide Title", guide.meta_description_or_fallback

    guide.meta_description = "Explicit SEO snippet"
    assert_equal "Explicit SEO snippet", guide.meta_description_or_fallback
  end

  test "edge cases: tag parsing with empty, duplicate, extra spaces, and nil" do
    guide = TravelGuide.new(title: "Tag Edge Cases")

    guide.tag_list = ""
    assert_equal [], guide.tags
    assert_equal "", guide.tag_list

    guide.tag_list = nil
    assert_equal [], guide.tags
    assert_equal "", guide.tag_list

    guide.tag_list = "  Trabzon  ,   Trabzon  ,   Uzungöl   ,   "
    assert_equal ["Trabzon", "Uzungöl"], guide.tags
    assert_equal "Trabzon, Uzungöl", guide.tag_list
  end

  test "edge cases: very long title truncates auto-generated slug to 100 characters" do
    long_title = "A" * 300
    guide = TravelGuide.create!(title: long_title)
    assert_operator guide.slug.length, :<=, 100
    assert guide.valid?
  end

  test "edge cases: duplicate custom slug fails validation" do
    TravelGuide.create!(title: "First Guide", slug: "custom-slug")
    duplicate = TravelGuide.new(title: "Second Guide", slug: "custom-slug")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "edge cases: missing cover image and no body images persist and render safely" do
    guide = TravelGuide.create!(
      title: "No Image Guide",
      content: "Simple text content without images"
    )
    assert_not guide.image.attached?
    assert_not guide.body_images.attached?
    assert_equal "<p>Simple text content without images</p>", guide.sanitized_content.strip
  end

  test "edge cases: future published_at date is treated as draft" do
    guide = TravelGuide.create!(
      title: "Future Article",
      active: true,
      published_at: 5.days.from_now
    )
    assert_not guide.published?
    assert guide.draft?
    assert_includes TravelGuide.draft, guide
    assert_not_includes TravelGuide.published, guide
  end
end
