require "test_helper"

# ─────────────────────────────────────────────
# Tour Card Rendering Tests
# ─────────────────────────────────────────────
class TourCardTest < ActionDispatch::IntegrationTest
  setup do
    # Destroy fixture tours so we control exactly what's visible
    Tour.where(active: true).destroy_all
    BusinessSetting.create!(company_name: "Test") unless BusinessSetting.exists?
    Rails.cache.clear
  end

  def build_tour(attrs = {})
    defaults = {
      title_en: "Uzungöl Tour",
      description_en: "Beautiful lake tour.",
      slug: "uzungol-#{SecureRandom.hex(4)}",
      active: true
    }
    Tour.create!(defaults.merge(attrs))
  end

  # --- duration ---

  test "tour card shows duration when present" do
    build_tour(duration: "Full Day")
    get tours_path
    assert_response :success
    assert_match "Full Day", response.body
  end

  test "tour card does not render duration chip when duration is blank" do
    build_tour(duration: nil, tour_type: nil)
    get tours_path
    assert_response :success
    # chip wrapper is only rendered when duration OR tour_type is present
    assert_no_match(/flex flex-wrap gap-2 mb-3/, response.body)
  end

  # --- tour_type ---

  test "tour card shows tour_type when present" do
    build_tour(tour_type: "Private")
    get tours_path
    assert_response :success
    assert_match "Private", response.body
  end

  test "tour card does not show tour_type chip when tour_type is blank" do
    build_tour(duration: nil, tour_type: nil)
    get tours_path
    assert_response :success
    assert_no_match(/flex flex-wrap gap-2 mb-3/, response.body)
  end

  # --- both chips together ---

  test "tour card shows both duration and tour_type chips when both present" do
    build_tour(duration: "8 Hours", tour_type: "Group")
    get tours_path
    assert_response :success
    assert_match "8 Hours", response.body
    assert_match "Group", response.body
  end

  test "tour card with no metadata renders no chip container" do
    build_tour(duration: nil, tour_type: nil)
    get tours_path
    assert_response :success
    assert_no_match(/flex flex-wrap gap-2 mb-3/, response.body)
  end

  # --- featured badge ---

  test "tour card shows Featured badge for featured tours" do
    build_tour(featured: true)
    get tours_path
    assert_response :success
    assert_match I18n.t("tours.card.featured"), response.body
  end

  test "tour card does NOT show Featured badge for non-featured tours" do
    build_tour(featured: false)
    get tours_path
    assert_response :success
    assert_no_match I18n.t("tours.card.featured"), response.body
  end

  # --- price from label ---

  test "tour card shows localized From label when price_from present" do
    build_tour(price_from: 99, currency: "USD")
    get tours_path
    assert_response :success
    assert_match I18n.t("tours.card.from"), response.body
    assert_match "USD 99", response.body
  end

  test "tour card shows no price row when price_from is nil" do
    build_tour(price_from: nil)
    get tours_path
    assert_response :success
    assert_no_match I18n.t("tours.card.from"), response.body
  end
end

# ─────────────────────────────────────────────
# Locale-Aware Tour Search Tests
# ─────────────────────────────────────────────
class TourSearchTest < ActionDispatch::IntegrationTest
  setup do
    Tour.where(active: true).destroy_all
    BusinessSetting.create!(company_name: "Test") unless BusinessSetting.exists?
    Rails.cache.clear

    @en_tour = Tour.create!(
      title_en: "Uzungöl Day Trip",
      description_en: "A beautiful lake surrounded by mountains.",
      slug: "uzungol-search-test",
      active: true
    )

    # Tour with Arabic translation in JSONB
    @ar_tour = Tour.create!(
      title_en: "Ayder Plateau",
      description_en: "Lush highland plateau.",
      slug: "ayder-search-test",
      active: true
    )
    @ar_tour.update_column(:translations, {
      "en" => { "title" => "Ayder Plateau", "description" => "Lush highland plateau.",
                "included" => [], "excluded" => [], "highlights" => [], "itinerary" => [],
                "meeting_point" => nil, "cancellation_policy" => nil },
      "ar" => { "title" => "هضبة أيدر", "description" => "هضبة خضراء جميلة.",
                "included" => [], "excluded" => [], "highlights" => [], "itinerary" => [],
                "meeting_point" => nil, "cancellation_policy" => nil }
    })

    # Tour with Turkish translation in JSONB
    @tr_tour = Tour.create!(
      title_en: "Sumela Monastery",
      description_en: "Historic cliff monastery.",
      slug: "sumela-search-test",
      active: true
    )
    @tr_tour.update_column(:translations, {
      "en" => { "title" => "Sumela Monastery", "description" => "Historic cliff monastery.",
                "included" => [], "excluded" => [], "highlights" => [], "itinerary" => [],
                "meeting_point" => nil, "cancellation_policy" => nil },
      "tr" => { "title" => "Sumela Manastiri", "description" => "Tarihi kaya manastiri.",
                "included" => [], "excluded" => [], "highlights" => [], "itinerary" => [],
                "meeting_point" => nil, "cancellation_policy" => nil }
    })
  end

  # --- English search ---

  test "English search finds English title" do
    get tours_path, params: { q: "Uzungöl" }
    assert_response :success
    assert_match "Uzungöl Day Trip", response.body
    assert_no_match "Ayder Plateau", response.body
    assert_no_match "Sumela Monastery", response.body
  end

  test "English search finds English description" do
    get tours_path, params: { q: "mountains" }
    assert_response :success
    assert_match "Uzungöl Day Trip", response.body
  end

  test "English search returns no results for non-matching term" do
    get tours_path, params: { q: "nonexistentxyz" }
    assert_response :success
    assert_no_match "Uzungöl Day Trip", response.body
    assert_no_match "Ayder Plateau", response.body
  end

  # --- Arabic search ---

  test "Arabic search finds Arabic title in JSONB" do
    I18n.locale = :ar
    get "/ar/tours", params: { q: "هضبة أيدر" }
    assert_response :success
    # The tour card renders the translated title "هضبة أيدر" from JSONB
    assert_match "هضبة أيدر", response.body
  end

  test "Arabic search finds Arabic description in JSONB" do
    I18n.locale = :ar
    get "/ar/tours", params: { q: "خضراء" }
    assert_response :success
    assert_match "هضبة أيدر", response.body
  end

  test "Arabic search falls back to English content when Arabic translation is missing" do
    I18n.locale = :ar
    get "/ar/tours", params: { q: "Uzungöl" }
    assert_response :success
    # @en_tour has no Arabic translation — English fallback must surface it
    assert_match "Uzungöl Day Trip", response.body
  end

  test "Arabic search does not return unrelated tours" do
    I18n.locale = :ar
    get "/ar/tours", params: { q: "هضبة أيدر" }
    assert_response :success
    # Sumela should not appear — no match in AR or EN
    assert_no_match "Sumela", response.body
    assert_no_match "Uzungöl Day Trip", response.body
  end

  # --- Turkish search ---

  test "Turkish search finds Turkish title" do
    I18n.locale = :tr
    get "/tr/tours", params: { q: "Manastiri" }
    assert_response :success
    assert_match "Sumela", response.body
  end

  test "Turkish search finds Turkish description" do
    I18n.locale = :tr
    get "/tr/tours", params: { q: "kaya" }
    assert_response :success
    assert_match "Sumela", response.body
  end

  test "Turkish search falls back to English when Turkish translation is missing" do
    I18n.locale = :tr
    get "/tr/tours", params: { q: "Uzungöl" }
    assert_response :success
    assert_match "Uzungöl Day Trip", response.body
  end

  # --- Existing filters still work alongside search ---

  test "destination filter still works independently of search" do
    dest = Destination.create!(name: "Uzungol Test Dest", slug: "uzungol-dest-#{SecureRandom.hex(4)}", active: true)
    @en_tour.update!(destination_id: dest.id)

    get tours_path, params: { destination_id: dest.id }
    assert_response :success
    assert_match "Uzungöl Day Trip", response.body
    assert_no_match "Ayder Plateau", response.body
  end

  test "tour_type filter still works independently of search" do
    @en_tour.update!(tour_type: "Private")

    get tours_path, params: { tour_type: "Private" }
    assert_response :success
    assert_match "Uzungöl Day Trip", response.body
    assert_no_match "Ayder Plateau", response.body
  end

  test "search and tour_type filter can be combined" do
    @en_tour.update!(tour_type: "Private")

    get tours_path, params: { q: "Uzungöl", tour_type: "Private" }
    assert_response :success
    assert_match "Uzungöl Day Trip", response.body

    get tours_path, params: { q: "Uzungöl", tour_type: "Group" }
    assert_response :success
    assert_no_match "Uzungöl Day Trip", response.body
  end
end
