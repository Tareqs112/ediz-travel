require "test_helper"

class BusinessSettingTest < ActiveSupport::TestCase
  test "singleton_guard prevents multiple records" do
    BusinessSetting.create!(singleton_guard: true)

    setting2 = BusinessSetting.new(singleton_guard: true)
    assert_not setting2.save
  end

  test "validates email format" do
    setting = BusinessSetting.new(singleton_guard: true, contact_email: "invalid_email")
    assert_not setting.save

    setting.contact_email = "test@example.com"
    assert setting.save
  end

  test "current creates default record if none exists" do
    assert_equal 0, BusinessSetting.count

    setting = BusinessSetting.current
    assert_equal '61 EDİZ TRAVEL', setting.company_name
    assert_equal '+905540171890', setting.whatsapp_number
    assert_equal 1, BusinessSetting.count
  end
end
