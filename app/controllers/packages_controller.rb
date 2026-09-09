class PackagesController < ApplicationController
  def index
    @packages = Package.where(active: true).with_attached_image.order(created_at: :desc)
  end

  def show
    @package = Package.includes(:destinations, :tours).find_by!(slug: params[:slug], active: true)
  end
end
