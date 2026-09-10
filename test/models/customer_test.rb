require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "should save valid customer" do
    customer = Customer.new(name: "John Doe", phone: "+123456789")
    assert customer.save
    assert_equal "en", customer.preferred_language
  end

  test "should not save customer without name" do
    customer = Customer.new(phone: "+123456789")
    assert_not customer.save
  end

  test "should validate preferred language" do
    customer = Customer.new(name: "Jane", preferred_language: "fr")
    assert_not customer.save

    customer.preferred_language = "ar"
    assert customer.save
  end

  test "allows shared phone numbers" do
    Customer.create!(name: "Wife", phone: "555-0000")
    husband = Customer.new(name: "Husband", phone: "555-0000")
    assert husband.save
  end

  test "allows optional email and phone" do
    customer = Customer.new(name: "Mystery Person")
    assert customer.save
  end
end
