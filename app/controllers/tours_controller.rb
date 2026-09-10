class ToursController < ApplicationController
  def index
    @tours = Tour.where(active: true).with_attached_image

    if params[:q].present?
      search_term = "%#{params[:q]}%"
      locale = I18n.locale.to_s

      # Whitelist the locale against known supported locales to prevent any
      # possibility of injecting a locale key into a JSONB path.
      safe_locale = I18n.available_locales.map(&:to_s).include?(locale) ? locale : "en"

      if safe_locale == "en"
        # English: search legacy column (fast, indexed) OR translations JSONB for robustness
        @tours = @tours.where(
          "title ILIKE :term OR description ILIKE :term OR translations->'en'->>'title' ILIKE :term OR translations->'en'->>'description' ILIKE :term",
          term: search_term
        )
      else
        # Non-English: search translated content for the current locale first,
        # then fall back to English so tours with only English content are still found.
        @tours = @tours.where(
          "translations->:loc->>'title' ILIKE :term OR translations->:loc->>'description' ILIKE :term OR translations->'en'->>'title' ILIKE :term OR translations->'en'->>'description' ILIKE :term",
          loc: safe_locale, term: search_term
        )
      end
    end

    if params[:destination_id].present?
      @tours = @tours.where(destination_id: params[:destination_id])
    end

    if params[:tour_type].present?
      @tours = @tours.where(tour_type: params[:tour_type])
    end

    @tours = case params[:sort]
             when "oldest"
               @tours.order(created_at: :asc)
             when "title_asc"
               @tours.order(title: :asc)
             when "title_desc"
               @tours.order(title: :desc)
             else # "newest" or default
               @tours.order(created_at: :desc)
             end
  end

  def show
    @tour = Tour.where(active: true).with_attached_image.find_by!(slug: params[:slug])
    @related_tours = Tour.where(active: true).where.not(id: @tour.id).with_attached_image.limit(3)
  end
end
