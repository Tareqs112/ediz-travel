require "test_helper"

class DestinationTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    destination = Destination.new(name: "Trabzon", slug: "trabzon-test")
    assert destination.valid?
  end

  test "should require name" do
    destination = Destination.new(slug: "test")
    assert_not destination.valid?
  end

  test "should require slug" do
    destination = Destination.new(name: "Test")
    assert_not destination.valid?
  end

  test "slug should be unique" do
    Destination.create!(name: "Test", slug: "test-slug")
    duplicate = Destination.new(name: "Another", slug: "test-slug")
    assert_not duplicate.valid?
  end
end
