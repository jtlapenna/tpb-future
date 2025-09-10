require 'rails_helper'

describe ShareProductTextMessageJob do
  let(:store) { create :store, enabled_share_sms_product: true }
  let(:category) { create :store_category, store: store }
  let(:product) { create :store_product, store_category: category, share_sms_template: 'some sms template' }

  let(:job) { described_class.new }

  before do
    ENV['TWILIO_ACCOUNT_SID'] = 'twilio_sid'
    ENV['TWILIO_API_KEY'] = 'twilio_key'
    ENV['TWILIO_API_SECRET'] = 'twilio_secret'
    ENV['TWILIO_NUMBER_FROM'] = 'twilio_from'
  end

  it 'use twilio to send sms' do
    message_service = double('twilio_message_service')
    twilio_client = double('twilio_mock', messages: message_service)

    expect(Twilio::REST::Client).to receive(:new).with('twilio_key', 'twilio_secret', 'twilio_sid').and_return(twilio_client)
    expect(message_service).to receive(:create).with(body: 'some sms template', from: 'twilio_from', to: '+1234')

    job.perform(product, '+1234')
  end

  it "don't send sms to empty phone numbers" do
    expect(Twilio::REST::Client).not_to receive(:new)

    job.perform(product, '')
  end

  it "don't send sms when product has no template" do
    expect(Twilio::REST::Client).not_to receive(:new)

    product.update(share_sms_template: nil)

    job.perform(product, '+1234')
  end

  it "don't send sms when store has share disabled" do
    expect(Twilio::REST::Client).not_to receive(:new)

    store.update(enabled_share_sms_product: false)

    job.perform(product, '+1234')
  end

  context 'when delivery method is set to ez_texting' do
    before do
      ENV['SMS_DELIVERY_METHOD'] = 'ez_texting'
      ENV['EZ_TEXTING_USER'] = 'ez_texting_user'
      ENV['EZ_TEXTING_PASSWORD'] = 'ez_texting_password'
    end

    it 'use ez texting to send sms' do
      message_service = double('ez_texting mock')

      expect(EzTexting::Client).to receive(:new).with('ez_texting_user', 'ez_texting_password').and_return(message_service)
      expect(message_service).to receive(:send_message).with(body: 'some sms template', to: '+1234')

      job.perform(product, '+1234')
    end

    it "don't send sms to empty phone numbers" do
      expect(EzTexting::Client).not_to receive(:new)

      job.perform(product, '')
    end

    it "don't send sms when product has no template" do
      expect(EzTexting::Client).not_to receive(:new)

      product.update(share_sms_template: nil)

      job.perform(product, '+1234')
    end

    it "don't send sms when store has share disabled" do
      expect(EzTexting::Client).not_to receive(:new)

      store.update(enabled_share_sms_product: false)

      job.perform(product, '+1234')
    end
  end
end
