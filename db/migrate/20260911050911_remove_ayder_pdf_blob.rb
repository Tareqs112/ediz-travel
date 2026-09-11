class RemoveAyderPdfBlob < ActiveRecord::Migration[8.1]
  def up
    # Targeted data cleanup for Ayder tour PDF bug on Render
    tour = Tour.find_by(slug: 'ayder-firtina')
    
    if tour && tour.image.attached?
      blob = tour.image.blob
      
      # 1. Target exactly Ayder tour image
      # 2. Attached blob ID is exactly 8
      # 3. Content type is exactly application/pdf
      if blob && blob.id == 8 && blob.content_type == 'application/pdf'
        puts "RemoveAyderPdfBlob: Confirmed blob ID 8 (PDF) on Ayder tour. Purging..."
        
        # 3. Purge ONLY that image attachment/blob
        tour.image.purge
        
        puts "RemoveAyderPdfBlob: Successfully purged."
      else
        puts "RemoveAyderPdfBlob: Safety check failed. Blob is ID #{blob&.id} (#{blob&.content_type}). Doing nothing."
      end
    else
      puts "RemoveAyderPdfBlob: Ayder tour not found or no image attached. Doing nothing."
    end
  end

  def down
    # Data migration is irreversible
    raise ActiveRecord::IrreversibleMigration
  end
end
