ActiveSupport.on_load(:active_storage_attachment) do
  after_commit :enqueue_optimization_job, on: :create

  private

  def enqueue_optimization_job
    # Only process images that haven't been optimized yet
    return unless blob&.image?
    return if blob.metadata[:optimized]

    if Rails.env.production? || ENV['ENABLE_IMAGE_OPTIMIZATION'] == 'true'
      OptimizeImageJob.perform_later(self)
    end
  end
end
