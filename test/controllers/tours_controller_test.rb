require "test_helper"

class ToursControllerTest < ActionDispatch::IntegrationTest
  setup do
    @active_tour = tours(:one)
    @inactive_tour = tours(:two)
  end

  test "should get index" do
    get tours_url
    assert_response :success
  end

  test "should show active tour" do
    get tour_url(@active_tour.slug)
    assert_response :success
  end

  test "should return 404 for inactive tour" do
    get tour_url(@inactive_tour.slug)
    assert_response :not_found
  end

  test "should return 404 for nonexistent tour" do
    get tour_url("non-existent-slug")
    assert_response :not_found
  end

  test "should filter by search query" do
    get tours_url(q: @active_tour.title)
    assert_response :success
  end

  test "should filter by destination" do
    get tours_url(destination_id: @active_tour.destination_id)
    assert_response :success
  end

  test "should filter by tour type" do
    get tours_url(tour_type: @active_tour.tour_type)
    assert_response :success
  end

  test "should sort by title asc" do
    get tours_url(sort: "title_asc")
    assert_response :success
  end

  test "should combine filters" do
    get tours_url(q: @active_tour.title, destination_id: @active_tour.destination_id, sort: "newest")
    assert_response :success
  end
end
