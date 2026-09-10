module Admin
  class TravelGuidesController < BaseController
    before_action :set_travel_guide, only: %i[show edit update destroy preview publish unpublish remove_body_image]

    def index
      @status = params[:status].presence || "all"
      @total_count = TravelGuide.count
      @published_count = TravelGuide.published.count
      @draft_count = TravelGuide.draft.count

      @travel_guides = case @status
                       when "published"
                         TravelGuide.published
                       when "draft"
                         TravelGuide.draft
                       else
                         TravelGuide.all
                       end.with_attached_image.order(updated_at: :desc)
    end

    def show
    end

    def new
      @travel_guide = TravelGuide.new(active: false)
    end

    def create
      @travel_guide = TravelGuide.new(travel_guide_params)
      apply_publishing_action

      if @travel_guide.save
        notice_message = @travel_guide.published? ? "Article successfully published." : "Article saved as draft."
        redirect_to admin_travel_guides_path, notice: notice_message
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      apply_publishing_action

      if @travel_guide.update(travel_guide_params)
        notice_message = @travel_guide.published? ? "Article updated and published." : "Article updated (saved as draft)."
        redirect_to admin_travel_guides_path, notice: notice_message
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @travel_guide.destroy
      redirect_to admin_travel_guides_path, notice: "Article '#{@travel_guide.title}' deleted."
    end

    def preview
      @is_preview = true
      @related_guides = TravelGuide.published.where.not(id: @travel_guide.id).with_attached_image.order(published_at: :desc).limit(3)
      render "travel_guides/show", layout: "application"
    end

    def publish
      @travel_guide.publish!
      redirect_back fallback_location: admin_travel_guides_path, notice: "Article '#{@travel_guide.title}' published."
    end

    def unpublish
      @travel_guide.unpublish!
      redirect_back fallback_location: admin_travel_guides_path, notice: "Article '#{@travel_guide.title}' unpublished (saved as draft)."
    end

    def upload_image
      file = params[:file] || params[:image]
      if file.present?
        blob = ActiveStorage::Blob.create_and_upload!(
          io: file,
          filename: file.original_filename,
          content_type: file.content_type
        )
        render json: { url: rails_blob_path(blob, only_path: true), id: blob.id, filename: blob.filename.to_s }
      else
        render json: { error: "No file provided" }, status: :unprocessable_entity
      end
    end

    def remove_body_image
      attachment = @travel_guide.body_images.find_by(id: params[:image_id])
      if attachment
        attachment.purge
        redirect_to edit_admin_travel_guide_path(@travel_guide), notice: "Image removed."
      else
        redirect_to edit_admin_travel_guide_path(@travel_guide), alert: "Image not found."
      end
    end

    private

    def set_travel_guide
      @travel_guide = TravelGuide.find_by!(slug: params[:slug])
    end

    def apply_publishing_action
      case params[:publication_action]
      when "publish"
        @travel_guide.active = true
        @travel_guide.published_at ||= Time.current
      when "save_draft"
        @travel_guide.active = false
      end
    end

    def travel_guide_params
  permit_args = [
    :slug, :active, :published_at,
    :image, :tag_list, tags: [], body_images: []
  ]
  [:en, :ar, :tr].each do |loc|
    permit_args += [:"title_#{loc}", :"excerpt_#{loc}", :"content_#{loc}", :"meta_description_#{loc}"]
  end
  params.require(:travel_guide).permit(*permit_args)
end
  end
end
