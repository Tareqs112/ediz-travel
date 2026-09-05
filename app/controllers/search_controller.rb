class SearchController < ApplicationController
  def index
    @query = params[:q]
    # We will use demo search results in the view
  end
end
