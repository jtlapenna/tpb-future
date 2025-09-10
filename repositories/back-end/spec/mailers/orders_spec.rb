require 'rails_helper'

describe OrdersMailer do
  let(:notification_settings) do
    {
      notifications_enabled: true,
      notifications_title: 'This is the title',
      notifications_recipients: ['a@a.com', 'b@b.com'],
      notifications_intro: 'Hi, thanks'
    }
  end
  let(:store) { create :store, notification_settings: notification_settings }
  let(:text_part) { mail.text_part.body.decoded }
  let(:html_part) { mail.html_part.body.decoded }
  let(:store_category) { store.store_categories.first }
  let(:product_values) do
    [
      build(:product_value, value: 10.25, valuable: nil),
      build(:product_value, value: 13.75, valuable: nil)
    ]
  end
  let(:products) do
    [
      create(:store_product, store_category: store_category, name: 'Product 1', product_values: [product_values[0]]),
      create(:store_product, store_category: store_category, name: 'Product 2', product_values: [product_values[1]]),
      create(:store_product, store_category: store_category, name: 'Product 3')
    ]
  end

  describe '#new_order' do
    let(:order) do
      {
        customer_name: 'Jon Snow',
        items: [
          { product_id: products[0].id, quantity: 2 },
          { product_id: products[1].id, quantity: 1, product_value_id: product_values[1].id },
          { product_id: products[2].id, quantity: 1, price_total: 10.25 }
        ]
      }
    end
    let(:mail) { OrdersMailer.new_order(store_id: store.id, order: order) }

    it 'renders the headers' do
      expect(mail.subject).to eq "This is the title [Jon Snow - #{I18n.l(Date.today, format: '%m/%d/%Y')}]"
      expect(mail.to).to eq ['a@a.com', 'b@b.com']
      expect(mail.from).to eq(['no-reply@thepeakbeyond.com'])
    end

    it 'renders the text version' do
      expect(text_part).to match 'Customer: Jon Snow'
      expect(text_part).to match 'Just submitted an order for:'
      expect(text_part).to match 'Product 1 2 \\$20.50'
      expect(text_part).to match 'Product 2 1 \\$13.75'
      expect(text_part).to match 'Product 3 1 \\$10.25'
      expect(text_part).to match 'Total: \\$44.50'
    end

    it 'renders the html body' do
      expect(html_part).to match '<p>Customer: Jon Snow </p>'
      expect(html_part).to match '<p>Just submitted an order for:</p>'
      expect(html_part).to match '<td>Product 1</td>'
      expect(html_part).to match '<td align="right">\\$20.50</td>'
      expect(html_part).to match '<td>Product 2</td>'
      expect(html_part).to match '<td align="right">\\$13.75</td>'
      expect(html_part).to match '<td>Product 3</td>'
      expect(html_part).to match '<td align="right">\\$10.25</td>'
      expect(html_part).to match '<td align="right">\\$44.50</td>'
    end

    context 'with customer email' do
      let(:mail) { OrdersMailer.new_order(store_id: store.id, order: order_params, customer_email: 'customer@customer.com') }
      let(:order_params) { order.merge(customer_email: 'customer@customer.com') }

      it 'renders the headers' do
        expect(mail.subject).to eq "This is the title [Jon Snow - #{I18n.l(Date.today, format: '%m/%d/%Y')}]"
        expect(mail.to).to eq ['customer@customer.com']
        expect(mail.from).to eq(['no-reply@thepeakbeyond.com'])
      end

      it 'renders the text intro' do
        expect(text_part).to match 'Hi, thanks'
        expect(html_part).to match 'Hi, thanks'
      end
    end

    context 'on updated order' do
      let(:mail) { OrdersMailer.new_order(store_id: store.id, order: order, is_update: true) }

      it 'add the [UPDATED] mark' do
        expect(text_part).to match 'Customer: Jon Snow \\[UPDATED\\]'
        expect(html_part).to match '<p>Customer: Jon Snow \\[UPDATED\\]</p>'
      end
    end
  end
end
