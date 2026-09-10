require "test_helper"

class Admin::BusinessSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @setting = BusinessSetting.current
  end

  test "should redirect unauthenticated user" do
    get edit_admin_business_setting_url
    assert_redirected_to new_session_url
  end

  test "should get edit for authenticated admin" do
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    get edit_admin_business_setting_url
    assert_response :success
  end

  test "should update business setting" do
    post session_url, params: { email_address: @admin.email_address, password: "password" }

    patch admin_business_setting_url, params: {
      business_setting: {
        company_name: "Updated Name",
        whatsapp_number: "+123456789"
      }
    }

    assert_redirected_to edit_admin_business_setting_url
    @setting.reload
    assert_equal "Updated Name", @setting.company_name
    assert_equal "+123456789", @setting.whatsapp_number
  end
end
