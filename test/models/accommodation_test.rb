require "test_helper"

class AccommodationTest < ActiveSupport::TestCase
  setup do
    @accommodation = Accommodation.new(
      name: "Uzungol Nature Bungalow",
      slug: "uzungol-nature-bungalow",
      accommodation_type: "bungalow",
      short_description: "A beautiful wooden bungalow near the lake.",
      location: "Uzungol, Trabzon"
    )
  end

  test "should be valid with valid attributes" do
    assert @accommodation.valid?
  end

  test "should require a name" do
    @accommodation.name = nil
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:name], "can't be blank"
  end

  test "should require a slug" do
    @accommodation.slug = nil
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:slug], "can't be blank"
  end

  test "should require a unique slug" do
    @accommodation.save!
    duplicate = Accommodation.new(
      name: "Another Name",
      slug: @accommodation.slug,
      accommodation_type: "hotel"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "should require an accommodation_type" do
    @accommodation.accommodation_type = nil
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:accommodation_type], "can't be blank"
  end

  test "should reject invalid accommodation_type" do
    assert_raises(ArgumentError) do
      @accommodation.accommodation_type = "spaceship"
    end
  end

  test "should have default active as true" do
    acc = Accommodation.new
    assert_equal true, acc.active
  end

  test "should have default featured as false" do
    acc = Accommodation.new
    assert_equal false, acc.featured
  end
end
