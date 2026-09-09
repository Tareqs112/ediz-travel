require "test_helper"

class PackagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @package = packages(:one)
    @package.update!(active: true)
  end

  test "should get index" do
    get packages_url
    assert_response :success
  end

  test "should show active package" do
    get package_url(@package)
    assert_response :success
  end

  test "should not show inactive package" do
    @package.update!(active: false)
    get package_url(@package)
    assert_response :not_found
  end
end
