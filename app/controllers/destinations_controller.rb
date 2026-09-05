class DestinationsController < ApplicationController
  def index
    # We will use demo data in the view since the model doesn't exist yet
  end

  def show
    # We will use demo data in the view
    @slug = params[:slug]
  end
end
