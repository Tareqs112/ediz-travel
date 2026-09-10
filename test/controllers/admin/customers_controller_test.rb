require "test_helper"

class Admin::CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    @customer = Customer.create!(name: "Jane Smith", phone: "+123456789")
  end

  test "should get index" do
    get admin_customers_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_customer_url
    assert_response :success
  end

  test "should create customer" do
    assert_difference("Customer.count") do
      post admin_customers_url, params: { customer: { name: "New Customer", preferred_language: "ar" } }
    end
    assert_redirected_to admin_customer_url(Customer.last)
  end

  test "should get show" do
    get admin_customer_url(@customer)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_customer_url(@customer)
    assert_response :success
  end

  test "should update customer" do
    patch admin_customer_url(@customer), params: { customer: { name: "Updated Name" } }
    assert_redirected_to admin_customer_url(@customer)
    @customer.reload
    assert_equal "Updated Name", @customer.name
  end

  test "should destroy customer" do
    assert_difference("Customer.count", -1) do
      delete admin_customer_url(@customer)
    end
    assert_redirected_to admin_customers_url
  end

  test "should redirect unauthenticated user" do
    delete session_url
    get admin_customers_url
    assert_redirected_to new_session_url
  end
end
