module SeoHelper
  # Returns the canonical URL for the current page, self-referencing to its own locale
  def canonical_url
    url_for(only_path: false)
  rescue StandardError
    root_url(locale: I18n.locale, only_path: false)
  end

  # Maps I18n locale to OpenGraph locale format
  def og_locale(locale = I18n.locale)
    case locale.to_sym
    when :ar then "ar_SA"
    when :tr then "tr_TR"
    else "en_US"
    end
  end
end
