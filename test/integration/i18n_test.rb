require "test_helper"

class I18nTest < ActionDispatch::IntegrationTest
  test "default locale is en with dir ltr" do
    get "/"
    assert_response :success
    assert_select "html[lang='en'][dir='ltr']"
  end

  test "explicit en locale renders en with dir ltr" do
    get "/en"
    assert_response :success
    assert_select "html[lang='en'][dir='ltr']"
  end

  test "ar locale renders ar with dir rtl and arabic font" do
    get "/ar"
    assert_response :success
    assert_select "html[lang='ar'][dir='rtl']"
    assert_select "body.font-arabic"
  end

  test "tr locale renders tr with dir ltr" do
    get "/tr"
    assert_response :success
    assert_select "html[lang='tr'][dir='ltr']"
    assert_select "body.font-sans"
  end

  test "invalid locale falls back safely to en without error" do
    get "/de/tours"
    assert_response :success
    assert_equal :en, I18n.locale
    assert_select "html[lang='en'][dir='ltr']"

    get "/?locale=invalid_locale"
    assert_response :success
    assert_equal :en, I18n.locale
  end

  test "language switcher exists in navbar with all supported locales" do
    get "/"
    assert_response :success
    assert_select "a[href='/']", text: /English/
    assert_select "a[href='/ar']", text: /العربية/
    assert_select "a[href='/tr']", text: /Türkçe/
  end

  test "language switcher on subpages preserves subpage path" do
    get "/tours"
    assert_response :success
    assert_select "a[href='/tours']", text: /English/
    assert_select "a[href='/ar/tours']"
    assert_select "a[href='/tr/tours']"
  end

  test "tours page renders localized UI across en, ar, and tr without missing translations" do
    [:en, :ar, :tr].each do |loc|
      path = loc == :en ? "/tours" : "/#{loc}/tours"
      get path
      assert_response :success
      assert_not_includes response.body, "translation missing"
    end

    get "/en/tours"
    assert_select "h1", text: /Discover Tours/

    get "/ar/tours"
    assert_select "h1", text: /استكشف الجولات/

    get "/tr/tours"
    assert_select "h1", text: /Turları Keşfedin/
  end

  test "services pages render localized UI across en, ar, and tr without missing translations" do
    pages = [
      "/services",
      "/services/airport-transfer",
      "/services/car-rental",
      "/services/chauffeured-car",
      "/services/private-tours"
    ]

    pages.each do |page|
      [:en, :ar, :tr].each do |loc|
        path = loc == :en ? page : "/#{loc}#{page}"
        get path
        assert_response :success
        assert_not_includes response.body, "translation missing"
      end
    end
  end

  test "contact and about and faq pages render localized UI without missing translations" do
    [:en, :ar, :tr].each do |loc|
      [about_path(locale: loc), contact_path(locale: loc), faq_path(locale: loc), packages_path(locale: loc), accommodations_path(locale: loc), travel_guides_path(locale: loc)].each do |path|
        get path
        assert_response :success
        assert_not_includes response.body, "translation missing"
      end
    end
  end

  test "company name and legal details remain intact across all locales" do
    [:en, :ar, :tr].each do |loc|
      path = loc == :en ? "/" : "/#{loc}"
      get path
      assert_response :success
      assert_includes response.body, "61 EDİZ TRAVEL"
      assert_includes response.body, "15956"
      assert_includes response.body, "LAZ TUR TURİZM İNŞAAT TİCARET LİMİTED ŞİRKETİ"
    end
  end

  test "admin routes remain in English and outside locale scope" do
    get "/admin/session/new"
    assert_response :success
    assert_equal :en, I18n.locale
    assert_not_includes response.body, "translation missing"
  end
end
