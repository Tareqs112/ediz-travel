class UpdateHeroVideoCompressedBlob < ActiveRecord::Migration[8.1]
  def up
    blob = ActiveStorage::Blob.find_by(key: "hero.mp4")
    if blob
      blob.update_column(:byte_size, 988079)
      puts "Updated hero.mp4 blob byte_size to 988079"
    else
      puts "hero.mp4 blob not found, skipping."
    end
  end

  def down
    blob = ActiveStorage::Blob.find_by(key: "hero.mp4")
    if blob
      blob.update_column(:byte_size, 4686396)
      puts "Reverted hero.mp4 blob byte_size to 4686396"
    end
  end
end
