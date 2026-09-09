class ContactMessagesController < ApplicationController
  def create
    @contact_message = ContactMessage.new(contact_message_params)
    if @contact_message.save
      redirect_to contact_path, notice: t("contact.success_notice")
    else
      redirect_to contact_path, alert: t("contact.error_alert")
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :subject, :message)
  end
end
