require 'rails_helper'

ENV['DEFAULT_EMAIL_FROM'] = 'no-reply@thepeakbeyond.com'

describe ProductsMailer do
  let(:store) { create :store }
  let(:html_body) { '<br> Hi </br>' }
  let(:brand) { create(:brand) }
  let(:variant) { create :product_variant, brand: brand }
  let(:store_product) { create :store_product, store: store, share_email_template: html_body, brand: nil, product_variant: variant }
  let(:email) { 'anemail@mail.com' }

  describe '#share' do
    before { store.update(enabled_share_email_product: true) }

    let(:mail) { ProductsMailer.share(store_product, email) }

    it 'renders the headers' do
      expect(mail.subject).to eq "A note from #{brand.name}"
      expect(mail.to).to eq [email]
      expect(mail.from).to eq(['no-reply@thepeakbeyond.com'])
    end

    it 'renders the html body' do
      expect(mail.body).to match html_body
    end
  end
end
