class FixHeroVideoByteSize < ActiveRecord::Migration[8.1]
  def up
    blob = ActiveStorage::Blob.find_by(key: "hero.mp4")
    blob&.update_columns(byte_size: 4_687_363)
    puts "FixHeroVideoByteSize: Updated hero.mp4 blob byte_size to 4687363"
  end

  def down
    # Irreversible/noop
  end
end
