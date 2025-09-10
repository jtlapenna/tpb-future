class ShareProductTextMessageJob < ApplicationJob
  queue_as :sms
  unique :until_executed

  def perform(product, phone)
    return if phone.blank?
    return if product.share_sms_template.blank?
    return unless product.store.enabled_share_sms_product?

    if ENV['SMS_DELIVERY_METHOD'] == 'ez_texting'
      ez_texting_client.send_message(
        body: product.share_sms_template,
        to: phone
      )
    else
      twilio_client.messages.create(
        body: product.share_sms_template,
        from: ENV['TWILIO_NUMBER_FROM'],
        to: phone
      )
    end
  end

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(
      ENV['TWILIO_API_KEY'],
      ENV['TWILIO_API_SECRET'],
      ENV['TWILIO_ACCOUNT_SID']
    )
  end

  def ez_texting_client
    @ez_texting_client ||= EzTexting::Client.new(
      ENV['EZ_TEXTING_USER'],
      ENV['EZ_TEXTING_PASSWORD']
    )
  end
end
