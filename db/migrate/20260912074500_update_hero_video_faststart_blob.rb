class UpdateHeroVideoFaststartBlob < ActiveRecord::Migration[8.1]
  def up
    blob = ActiveStorage::Blob.find_by(key: "hero.mp4")
    if blob
      blob.update_columns(
        byte_size: 4_686_396,
        checksum: "faststart-hero-mp4-checksum"
      )
      puts "UpdateHeroVideoFaststartBlob: Updated hero.mp4 blob byte_size to 4686396"
    end
  end

  def down
    blob = ActiveStorage::Blob.find_by(key: "hero.mp4")
    if blob
      blob.update_columns(byte_size: 4_687_363)
    end
  end
end
