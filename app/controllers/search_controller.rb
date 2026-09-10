class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip

    if @query.present?
      search_term = "%#{@query}%"
      locale = I18n.locale.to_s
      safe_locale = I18n.available_locales.map(&:to_s).include?(locale) ? locale : "en"

      # Tour Search (Localized via JSONB)
      if safe_locale == "en"
        tour_clause = "title ILIKE :term OR description ILIKE :term OR translations->'en'->>'title' ILIKE :term OR translations->'en'->>'description' ILIKE :term"
        @tours = Tour.where(active: true).where(tour_clause, term: search_term).with_attached_image
      else
        tour_clause = "translations->:loc->>'title' ILIKE :term OR translations->:loc->>'description' ILIKE :term OR translations->'en'->>'title' ILIKE :term OR translations->'en'->>'description' ILIKE :term"
        @tours = Tour.where(active: true).where(tour_clause, loc: safe_locale, term: search_term).with_attached_image
      end

      # Package Search (Legacy, no Mobility)
      @packages = Package.where(active: true).where("title ILIKE :term OR description ILIKE :term", term: search_term).with_attached_image
    else
      @tours = Tour.none
      @packages = Package.none
    end
  end
end
