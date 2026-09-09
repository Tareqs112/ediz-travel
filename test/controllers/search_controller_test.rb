require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get search_url
    assert_response :success
  end

  test "should return matching tours and packages for query" do
    get search_url, params: { q: "Ayder" }
    assert_response :success
  end

  test "should handle query with no matches" do
    get search_url, params: { q: "NonexistentTourXYZ123" }
    assert_response :success
    assert_select "p", /couldn't find any tours or packages/
  end

  test "should not return inactive tours in search results" do
    tours(:two).update!(active: false, title: "Secret Inactive Tour")
    get search_url, params: { q: "Secret Inactive" }
    assert_response :success
    assert_select "p", /couldn't find any tours or packages/
    assert_no_match "Secret Inactive Tour", response.body
  end
end
