class Admin::BusinessSettingsController < Admin::BaseController
  before_action :set_business_setting

  def edit
  end

  def update
    if @business_setting.update(business_setting_params)
      redirect_to edit_admin_business_setting_path, notice: "Business information was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_business_setting
    @business_setting = BusinessSetting.current
  end

  def business_setting_params
    params.require(:business_setting).permit(
      :company_name,
      :whatsapp_number,
      :contact_email,
      :address,
      :tursab_number,
      :google_maps_url,
      :booking_policies
    )
  end
end
