class BusinessSetting < ApplicationRecord
  # Ensure only one record can exist
  validates :singleton_guard, presence: true, uniqueness: true

  # Basic format validations
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  def self.current
    Rails.cache.fetch("business_setting_current", expires_in: 12.hours) do
      first_or_create!(
        company_name: '61 EDİZ TRAVEL',
        whatsapp_number: '+905540171890',
        tursab_number: '15956',
        singleton_guard: true
      )
    end
  end

  after_save :clear_cache
  after_destroy :clear_cache

  private

  def clear_cache
    Rails.cache.delete("business_setting_current")
  end
end
