ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def teardown
      super
      I18n.locale = I18n.default_locale
    end
  end
end

module DefaultUrlOptionsIntegrationSession
  def default_url_options
    { locale: (I18n.locale == I18n.default_locale ? nil : I18n.locale) }
  end
end
ActionDispatch::Integration::Session.prepend(DefaultUrlOptionsIntegrationSession)

