require 'vips'

class OptimizeImageJob < ApplicationJob
  queue_as :default

  # If the attachment is deleted before the job runs, ignore it.
  discard_on ActiveJob::DeserializationError

  def perform(attachment)
    return unless attachment
    
    blob = attachment.blob
    
    # Sanity checks to ensure idempotency and safety
    return unless blob&.image?
    return if blob.metadata[:optimized]
    
    # Use blob.open which safely downloads the file to a tempfile
    blob.open do |tempfile|
      begin
        image = Vips::Image.new_from_file(tempfile.path)
        
        max_dim = 1920.0
        quality = 85
        optimized_buffer = nil
        
        ratio = [max_dim / image.width, max_dim / image.height, 1.0].min
        current_image = ratio < 1.0 ? image.resize(ratio) : image
        
        loop do
          optimized_buffer = current_image.write_to_buffer(".webp", Q: quality, strip: true)
          size_kb = optimized_buffer.bytesize / 1024.0
          
          break if size_kb <= 350 && size_kb <= 500
          
          if size_kb > 500
            if quality > 50
              quality -= 10
            else
              current_image = current_image.resize(0.8)
              quality = 70
              if current_image.width < 10
              Rails.logger.warn "OptimizeImageJob failed: Image cannot be compressed below 500KB (Attachment #{attachment.id})"
              optimized_buffer = nil
                break
              end
            end
          else
            if quality > 70
              quality -= 5
            else
              break
            end
          end
        end
        
        if optimized_buffer
          original_filename = blob.filename.to_s
          new_filename = original_filename.sub(/\.[^.]+$/, '.webp')
          
          new_blob = ActiveStorage::Blob.create_and_upload!(
            io: StringIO.new(optimized_buffer),
            filename: new_filename,
            content_type: 'image/webp',
            metadata: (blob.metadata || {}).merge(optimized: true)
          )
          
          ActiveRecord::Base.transaction do
            attachment.update!(blob: new_blob)
          end
          
          # Safely purge the old blob only if it is no longer attached to anything else
          blob.reload
          blob.purge_later if blob.attachments.count == 0
        end
      rescue Vips::Error => e
        Rails.logger.warn "OptimizeImageJob Vips failed for attachment #{attachment.id}: #{e.message}"
      rescue StandardError => e
        Rails.logger.error "OptimizeImageJob failed for attachment #{attachment.id}: #{e.message}"
        raise e # Re-raise other errors so the job queues for retry
      end
    end
  end
end
