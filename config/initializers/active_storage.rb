# frozen_string_literal: true

Rails.application.config.active_storage.content_types_allowed_inline << "video/mp4" unless Rails.application.config.active_storage.content_types_allowed_inline.include?("video/mp4")

Rails.application.config.to_prepare do
  ActiveStorage.content_types_allowed_inline << "video/mp4" unless ActiveStorage.content_types_allowed_inline.include?("video/mp4")
end
