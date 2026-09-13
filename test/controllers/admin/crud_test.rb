require "test_helper"

class Admin::CrudTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @tour = tours(:one)
    @destination = destinations(:one)
    @accommodation = accommodations(:one)
    
    # login as admin
    post session_url, params: { email_address: @admin.email_address, password: "password" }
  end

  # Tours
  test "should get tours index" do
    get admin_tours_url
    assert_response :success
  end

  test "should get tour show" do
    get admin_tour_url(@tour)
    assert_response :success
  end

  test "should get tour new" do
    get new_admin_tour_url
    assert_response :success
  end

  test "should create tour" do
    assert_difference("Tour.count") do
      post admin_tours_url, params: { tour: { title_en: "New Tour", slug: "new-tour", description_en: "Desc", active: true } }
    end
    assert_redirected_to admin_tour_url(Tour.last, locale: nil)
  end

  test "should update tour" do
    patch admin_tour_url(@tour), params: { tour: { title_en: "Updated Title" } }
    assert_redirected_to admin_tour_url(@tour, locale: nil)
    @tour.reload
    assert_equal "Updated Title", @tour.title
  end

  test "should destroy tour" do
    assert_difference("Tour.count", -1) do
      delete admin_tour_url(@tour)
    end
    assert_redirected_to admin_tours_url(locale: nil)
  end

  # Destinations
  test "should get destinations index" do
    get admin_destinations_url
    assert_response :success
  end

  test "should get destination show" do
    get admin_destination_url(@destination)
    assert_response :success
  end

  test "should get destination new" do
    get new_admin_destination_url
    assert_response :success
  end

  test "should create destination" do
    assert_difference("Destination.count") do
      post admin_destinations_url, params: { destination: { name: "New Dest", slug: "new-dest", description_en: "Desc", active: true } }
    end
    assert_redirected_to admin_destination_url(Destination.last, locale: nil)
  end

  test "should update destination" do
    patch admin_destination_url(@destination), params: { destination: { name: "Updated Dest" } }
    assert_redirected_to admin_destination_url(@destination, locale: nil)
    @destination.reload
    assert_equal "Updated Dest", @destination.name
  end

  test "should destroy destination" do
    assert_difference("Destination.count", -1) do
      delete admin_destination_url(@destination)
    end
    assert_redirected_to admin_destinations_url(locale: nil)
  end

  # Accommodations
  test "should get accommodations index" do
    get admin_accommodations_url
    assert_response :success
  end

  test "should get accommodation show" do
    get admin_accommodation_url(@accommodation)
    assert_response :success
  end

  test "should get accommodation new" do
    get new_admin_accommodation_url
    assert_response :success
  end

  test "should create accommodation" do
    assert_difference("Accommodation.count") do
      post admin_accommodations_url, params: { accommodation: { name: "New Acc", slug: "new-acc", description_en: "Desc", active: true, accommodation_type: "hotel" } }
    end
    assert_redirected_to admin_accommodation_url(Accommodation.last, locale: nil)
  end

  test "should update accommodation" do
    patch admin_accommodation_url(@accommodation), params: { accommodation: { name: "Updated Acc" } }
    assert_redirected_to admin_accommodation_url(@accommodation, locale: nil)
    @accommodation.reload
    assert_equal "Updated Acc", @accommodation.name
  end

  test "should destroy accommodation" do
    assert_difference("Accommodation.count", -1) do
      delete admin_accommodation_url(@accommodation)
    end
    assert_redirected_to admin_accommodations_url(locale: nil)
  end
test "should update tour itinerary" do
  patch admin_tour_url(@tour), params: { 
    tour: { 
      itinerary_en: [
        { day: "1", title: "Day 1", desc: "First day" },
        { day: "2", title: "", desc: "" } # Should be rejected
      ]
    }
  }
  assert_redirected_to admin_tour_url(@tour, locale: nil)
  @tour.reload
  assert_equal 1, @tour.itinerary.length
  assert_equal "Day 1", @tour.itinerary.first["title"]
end

end
