require "test_helper"

class Admin::PackagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @package = packages(:one)
    post session_url, params: { email_address: @admin.email_address, password: "password" }
  end

  test "should get index" do
    get admin_packages_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_package_url
    assert_response :success
  end

  test "should create package" do
    assert_difference("Package.count") do
      post admin_packages_url, params: { package: { title: "New Package", slug: "new-pkg", duration: "7 days", active: true } }
    end
    assert_redirected_to admin_package_url(Package.last, locale: nil)
  end

  test "should show package" do
    get admin_package_url(@package)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_package_url(@package)
    assert_response :success
  end

  test "should update package" do
    patch admin_package_url(@package), params: { package: { title: "Updated" } }
    assert_redirected_to admin_package_url(@package, locale: nil)
  end

  test "should destroy package" do
    assert_difference("Package.count", -1) do
      delete admin_package_url(@package)
    end
    assert_redirected_to admin_packages_url(locale: nil)
  end
end
