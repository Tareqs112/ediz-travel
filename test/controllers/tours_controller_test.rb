require "test_helper"

class ToursControllerTest < ActionDispatch::IntegrationTest
  setup do
    @active_tour = tours(:one) # assuming fixtures have an active tour
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
end
