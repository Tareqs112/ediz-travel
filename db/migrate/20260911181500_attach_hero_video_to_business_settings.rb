class AttachHeroVideoToBusinessSettings < ActiveRecord::Migration[8.1]
  def up
    # In production, Active Storage service is 'cloudflare'. In development/test, it is 'local' or 'test'.
    service_name = Rails.configuration.active_storage.service.to_s

    # Find or register the ActiveStorage::Blob referencing the existing hero.mp4 object in R2
    blob = ActiveStorage::Blob.find_or_initialize_by(key: "hero.mp4")
    blob.filename = "hero.mp4"
    blob.content_type = "video/mp4"
    blob.byte_size = 4_917_824 # ~4.69 MB
    blob.checksum = "hero-r2-video-checksum"
    blob.service_name = service_name
    blob.save!

    setting = BusinessSetting.current
    attachment = ActiveStorage::Attachment.find_or_initialize_by(
      name: "hero_video",
      record_type: "BusinessSetting",
      record_id: setting.id
    )
    attachment.blob = blob
    attachment.save!

    puts "AttachHeroVideoToBusinessSettings: Attached hero.mp4 blob (ID: #{blob.id}, service: #{service_name}) to BusinessSetting (ID: #{setting.id})"
  end

  def down
    setting = BusinessSetting.find_by(singleton_guard: true)
    if setting
      attachment = ActiveStorage::Attachment.find_by(
        name: "hero_video",
        record_type: "BusinessSetting",
        record_id: setting.id
      )
      attachment&.destroy
    end

    # Do NOT purge the R2 object on down migration!
    blob = ActiveStorage::Blob.find_by(key: "hero.mp4")
    blob&.destroy
  end
end
