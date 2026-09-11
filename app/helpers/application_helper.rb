module ApplicationHelper
  DURATION_TRANSLATIONS = {
    ar: {
      "Full Day (approx. 8–9 hours)" => "يوم كامل (حوالي 8-9 ساعات)",
      "Full Day (approx. 7–8 hours)" => "يوم كامل (حوالي 7-8 ساعات)",
      "Half to Full Day (approx. 5–7 hours)" => "نصف يوم إلى يوم كامل (حوالي 5-7 ساعات)",
      "Full Day (approx. 7–9 hours)" => "يوم كامل (حوالي 7-9 ساعات)",
      "Full Day (approx. 6–8 hours)" => "يوم كامل (حوالي 6-8 ساعات)",
      "Full Day (approx. 9–11 hours)" => "يوم كامل (حوالي 9-11 ساعة)",
      "Full Day (approx. 11–13 hours)" => "يوم كامل (حوالي 11-13 ساعة)",
      "Full Day (approx. 9–10 hours)" => "يوم كامل (حوالي 9-10 ساعات)"
    },
    tr: {
      "Full Day (approx. 8–9 hours)" => "Tam Gün (yaklaşık 8–9 saat)",
      "Full Day (approx. 7–8 hours)" => "Tam Gün (yaklaşık 7–8 saat)",
      "Half to Full Day (approx. 5–7 hours)" => "Yarım veya Tam Gün (yaklaşık 5–7 saat)",
      "Full Day (approx. 7–9 hours)" => "Tam Gün (yaklaşık 7–9 saat)",
      "Full Day (approx. 6–8 hours)" => "Tam Gün (yaklaşık 6–8 saat)",
      "Full Day (approx. 9–11 hours)" => "Tam Gün (yaklaşık 9–11 saat)",
      "Full Day (approx. 11–13 hours)" => "Tam Gün (yaklaşık 11–13 saat)",
      "Full Day (approx. 9–10 hours)" => "Tam Gün (yaklaşık 9–10 saat)"
    }
  }.freeze

  def localized_duration(duration_str)
    return "" if duration_str.blank?
    loc = I18n.locale.to_sym
    DURATION_TRANSLATIONS.dig(loc, duration_str) || duration_str
  end

  def localized_tour_type(tour_type)
    return t("tours.card.private", default: "Private") if tour_type.blank?
    case tour_type.to_s.downcase
    when "private", "private tour"
      case I18n.locale
      when :ar then "جولة خاصة"
      when :tr then "Özel Tur"
      else "Private Tour"
      end
    when "group", "group tour"
      case I18n.locale
      when :ar then "جولة جماعية"
      when :tr then "Grup Turu"
      else "Group Tour"
      end
    else
      tour_type
    end
  end

  def localized_destination_name(destination)
    return "" if destination.nil?
    t("destinations.#{destination.slug}", default: destination.name)
  end

  def hero_video_stream_url
    return nil unless current_business_setting&.hero_video&.attached?

    rails_storage_proxy_path(current_business_setting.hero_video, only_path: true)
  rescue StandardError => e
    Rails.logger.warn("Hero video proxy URL generation failed: #{e.message}")
    nil
  end
end
