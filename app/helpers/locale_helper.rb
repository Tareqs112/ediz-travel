module LocaleHelper
  LOCALE_NAMES = {
    en: "English",
    ar: "العربية",
    tr: "Türkçe"
  }.freeze

  def locale_display_name(locale = I18n.locale)
    LOCALE_NAMES[locale.to_sym] || locale.to_s.upcase
  end

  def rtl?(locale = I18n.locale)
    locale.to_sym == :ar
  end

  def switch_locale_path(target_locale)
    target_locale = target_locale.to_sym
    locale_param = (target_locale == I18n.default_locale) ? nil : target_locale

    return root_path(locale: locale_param) unless request.get?

    begin
      recognized = Rails.application.routes.recognize_path(request.path, method: request.request_method)
      merged_params = recognized.merge(request.query_parameters).merge(locale: locale_param)
      url_for(merged_params.merge(only_path: true))
    rescue StandardError
      root_path(locale: locale_param)
    end
  end
end
