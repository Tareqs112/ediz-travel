class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_locale

  def default_url_options
    if admin_or_sessions_controller?
      {}
    else
      { locale: (I18n.locale == I18n.default_locale ? nil : I18n.locale) }
    end
  end

  private

  def set_locale
    locale_param = params[:locale].to_s.downcase.presence
    if locale_param && I18n.available_locales.map(&:to_s).include?(locale_param)
      I18n.locale = locale_param.to_sym
      session[:locale] = I18n.locale
    else
      I18n.locale = I18n.default_locale
      session[:locale] = I18n.default_locale if locale_param.blank?
    end
  end

  def admin_or_sessions_controller?
    is_a?(Admin::BaseController) || is_a?(SessionsController)
  end
end
