require "test_helper"

class MobilityBehaviorTest < ActiveSupport::TestCase
  test "fallback behavior and cache correctness" do
    tour = Tour.new(title_en: "ENG Title")
    
    # 1. English value exists, Arabic/Turkish missing -> ar/tr must fall back to English.
    assert_equal "ENG Title", tour.title_ar
    assert_equal "ENG Title", tour.title_tr

    # 2. Assigning a translated value -> subsequent reads must return new value
    tour.title_ar = "AR Title"
    assert_equal "AR Title", tour.title_ar
    assert_equal "ENG Title", tour.title_en
    assert_equal "ENG Title", tour.title_tr

    # 3. Ensure array behavior
    tour.included_en = ["ENG Inc"]
    assert_equal ["ENG Inc"], tour.included_ar
    tour.included_ar = ["AR Inc"]
    assert_equal ["AR Inc"], tour.included_ar

    # 4. Save and reload behavior
    tour.slug = "test-slug-123"
    tour.description_en = "Desc"
    tour.save!
    
    tour.reload
    assert_equal "AR Title", tour.title_ar
    assert_equal "ENG Title", tour.title_tr
    assert_equal ["AR Inc"], tour.included_ar
    assert_equal ["ENG Inc"], tour.included_tr
    
    # 5. Emptying a field falls back to English
    tour.title_ar = ""
    assert_equal "ENG Title", tour.title_ar
    
    tour.included_ar = []
    assert_equal ["ENG Inc"], tour.included_ar
  end
end
