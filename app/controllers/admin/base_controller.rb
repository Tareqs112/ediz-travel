class Admin::BaseController < ApplicationController
  include Authentication
  layout "admin"

  before_action :set_admin_locale

  def default_url_options
    {}
  end

  private

  def set_admin_locale
    I18n.locale = :en
  end
end
