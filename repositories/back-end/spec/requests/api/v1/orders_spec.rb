require 'rails_helper'

describe 'API V1 Orders' do
  let(:kiosk) { create :kiosk, store: store }
  let(:product) { create :store_product, store: store, sku: 'some-sku' }

  describe 'catalog without integration' do
    include TreezApiHelper

    let(:store) { create :store, api_type: nil }

    describe 'create' do
      let(:order_params) { treez_create_order_params(product) }
      let(:params) { { order: order_params.merge(other: 'value') } }

      it "respond with message when catalog don't have api type nor email integration" do
        post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

        expect(json).to have_key 'message'
        expect(json['message']).to eq "catalog doesn't support this operation"
      end

      it "respond with message when catalog don't have api type" do
        notification_settings = {
          notifications_enabled: true,
          notifications_title: 'This is the title',
          notifications_recipients: ['a@a.com', 'b@b.com'],
          notifications_intro: 'Hi, thanks'
        }
        store.update!(notification_settings: notification_settings)

        post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

        params[:order].delete(:other)

        expect(json).to have_key 'order'
        expect(json['order']).to have_key 'customer_id'
        expect(json['order']).to have_key 'items'
      end
    end
  end

  shared_context 'notifications' do |is_update: nil|
    let(:params_with_email) do
      params[:order][:customer_email] = 'customer@customer.com'
      params
    end

    before do
      store.update!(
        notifications_enabled: true,
        notifications_title: 'a title',
        notifications_recipients: ['a@a.com'],
        notifications_intro: 'Hi, thanks!',
        notifications_send_to_customer: true
      )
    end

    it 'notify to customer if enabled' do
      expect do
        post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params_with_email
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob).twice

      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.once.with(
        'OrdersMailer', 'new_order', 'deliver_now', args: [store_id: store.id, order: hash_including(:items), is_update: is_update]
      )

      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.once.with(
        'OrdersMailer', 'new_order', 'deliver_now', args: [store_id: store.id, order: hash_including(:items), is_update: is_update, customer_email: 'customer@customer.com']
      )
    end

    it 'notify is enabled but not notify to customer' do
      store.update(notifications_send_to_customer: false)
      expect do
        post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params_with_email
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob).once

      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.once.with(
        'OrdersMailer', 'new_order', 'deliver_now', args: [store_id: store.id, order: hash_including(:items), is_update: is_update]
      )
    end

    it 'do not notify by email if disabled' do
      store.update(notifications_enabled: false)

      expect do
        post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params_with_email
      end.not_to have_enqueued_job
    end
  end

  shared_examples 'validate params' do
    it 'respond with missing parameter' do
      expect(api_mock).not_to receive(:create_order)

      post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: {}

      expect(json).to have_key 'message'
      expect(json['message']).to eq 'param is missing or the value is empty: order'
    end

    it 'respond with errors when data is not valid' do
      params = { order: order_params.merge(customer_id: nil) }
      params[:order][:items].first[:quantity] = 'a'
      params[:order][:items].first[:product_id] = ''

      expect(api_mock).not_to receive(:create_order)

      post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

      expected_errors = {
        'customer_id' => ["can't be blank"],
        'items.product_id' => ["can't be blank"],
        'items.quantity' => ['is not a number']
      }

      expect(json).to have_key 'errors'
      expect(json['errors']).to eq expected_errors
    end

    it 'respond with errors when product is from other catalog' do
      other_product = create :store_product

      params[:order][:items].first[:product_id] = other_product.id

      expect(api_mock).not_to receive(:create_order)

      post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

      expected_errors = {
        'items.product_id' => ['not found']
      }

      expect(json).to have_key 'errors'
      expect(json['errors']).to eq expected_errors
    end
  end

  shared_examples 'catch unexpected errors' do |error:|
    it 'respond with message when treez raise an unexpected error' do
      expect(api_mock).to receive(:create_order).with(create_order_params).and_raise error

      post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq 'unexpected error respone from the API. Detail: some error'
    end
  end

  describe 'catalog with treez integration' do
    include TreezApiHelper

    let(:store) { create :treez_store }
    let(:api_mock) { double(:treez_api_client) }

    before do
      allow(Treez::ApiClient).to receive(:new).with(store.treez_api_config).and_return api_mock
    end

    describe 'create' do
      let(:order_params) { treez_create_order_params(product) }
      let(:params) { { order: order_params.merge(other: 'value') } }
      let(:create_order_params) { { data: to_save_order_payload(order_params) } }
      let(:ticket_id) { treez_order[:ticket_id] }

      context 'first time the customer makes an order' do
        before { CustomerOrder.where(customer_id: treez_order[:customer_id]).delete_all }

        before { expect(api_mock).to receive(:create_order).with(create_order_params).and_return(treez_order) }

        it 'respond with created order' do
          post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

          expect(json).to have_key 'order'
          expect(json['order']).to eq order_response
        end

        it 'track new order' do
          expect do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
          end.to change {
            CustomerOrder.where(customer_id: treez_order[:customer_id]).count
          }.by 1

          expect(CustomerOrder.where(customer_id: treez_order[:customer_id]).last).to have_attributes order_id: ticket_id
        end

        include_context 'notifications'
      end

      context 'first time the customer makes an order for that catalog' do
        before { CustomerOrder.where(customer_id: treez_order[:customer_id]).delete_all }

        before { create :customer_order, customer_id: treez_order[:customer_id], store: create(:store) }

        before { expect(api_mock).to receive(:create_order).with(create_order_params).and_return(treez_order) }

        it 'respond with created order' do
          post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

          expect(json).to have_key 'order'
          expect(json['order']).to eq order_response
        end

        it 'track new order' do
          expect do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
          end.to change {
            CustomerOrder.where(customer_id: treez_order[:customer_id]).count
          }.by 1

          expect(CustomerOrder.where(customer_id: treez_order[:customer_id]).last).to have_attributes order_id: ticket_id, store_id: kiosk.store_id
        end
      end

      context 'second time existing previuos order, the customer makes an order' do
        let(:product2) { create :store_product, store: store, sku: '4321' }
        let!(:customer_order) { create :customer_order, customer_id: treez_order[:customer_id], order_id: ticket_id, store: kiosk.store }

        context 'when previous order is still IN PROCESS' do
          let(:params) { { order: { customer_id: '10000017', items: [treez_create_order_item_params(product), treez_create_order_item_params(product2, 3)] } } }
          let(:api_v2) { false }

          let(:order_params) do
            order = treez_create_order_params(product)
            # first item, quantity changed # second item is new
            items = [order[:items].first.merge(quantity: 2)] + [{ quantity: 3, price_total: 30.0, product_id: product2.id }]

            order.merge(id: ticket_id, items: items)
          end

          let(:treez_order_updated) { treez_order(api_v2: api_v2, products: [{ size_id: product.sku, quantity: 2 }, { size_id: product2.sku, quantity: 3 }]) }

          before do
            expect(api_mock).to receive(:get_order).with(ticket_id).and_return(treez_order(api_v2: api_v2, size_id: product.sku, status: 'AWAITING_PROCESSING'))
            expect(api_mock).to receive(:update_order).with(create_order_params).and_return(treez_order_updated)
          end

          it 'respond with updated order' do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

            expect(json).to have_key 'order'
            expect(json['order']).to eq to_peak_order(treez_order_updated).as_json
          end

          it 'track order usage' do
            expect do
              post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
            end.to change { customer_order.reload.updated_at }
          end

          include_context 'notifications', is_update: true

          context 'when client is using treez api v2' do
            let(:api_v2) { true }

            it 'track order usage' do
              expect do
                post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
              end.to change { customer_order.reload.updated_at }
            end
          end
        end

        context 'when previous order is not AWAITING PROCESSING' do
          before do
            expect(api_mock).to receive(:get_order).with(ticket_id).and_return(treez_order(products: [{ size_id: product.sku, quantity: 5 }], status: 'COMPLETE'))

            expect(api_mock).to receive(:create_order).with(create_order_params).and_return(treez_order)
          end

          it 'respond with updated order' do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

            expect(json).to have_key 'order'
            expect(json['order']).to eq order_response
          end

          it 'create new customer order' do
            expect do
              post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
            end.to change { CustomerOrder.where(customer_id: treez_order[:customer_id]).count }.by 1

            expect(CustomerOrder.where(customer_id: treez_order[:customer_id]).last).to have_attributes order_id: ticket_id
            expect(CustomerOrder.count).to eq 2
          end
        end
      end

      include_context 'validate params'

      it 'respond with conflict when order is duplicate' do
        expect(api_mock).to receive(:create_order).and_raise(treez_duplicate_order_error)

        post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params

        expect(json).to have_key 'message'
        expect(json['message']).to eq 'order already exists'
      end

      include_examples 'catch unexpected errors', error: Treez::TreezError.new('some error')

      def order_response
        to_peak_order(treez_order, order_params).as_json
      end
    end
  end

  describe 'catalog with flowhub integration' do
    include FlowhubApiHelper

    let(:store) { create :flowhub_store }
    let(:api_mock) { double(:flowhub_api_client) }

    before do
      allow(Flowhub::ApiClient).to receive(:new).with(store.flowhub_api_config).and_return api_mock
      allow(api_mock).to receive(:get_customer).with(flowhub_customer[:id]).and_return flowhub_customer
    end

    describe 'create' do
      let(:order_params) { flowhub_create_order_params(product) }
      let(:params) { { order: order_params.merge(other: 'value') } }
      let(:create_order_params) { { data: to_save_order_payload(order_params).merge(externalCreatedAt: anything) } }
      let(:order_id) { flowhub_order[:orderId] }
      let(:customer_id) { flowhub_customer[:id] }

      context 'first time the customer makes an order' do
        before { CustomerOrder.where(customer_id: flowhub_order[:customerId]).delete_all }

        before { expect(api_mock).to receive(:create_order).with(create_order_params).and_return(flowhub_order) }

        it 'respond with created order' do
          post api_v1_catalogs_orders_path(kiosk.id), params: params.to_json, headers: auth_headers(store, as_json: true)

          expect(json).to have_key 'order'
          expect(json['order']).to eq order_response
        end

        it 'track new order' do
          expect do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
          end.to change {
            CustomerOrder.where(customer_id: customer_id).count
          }.by 1

          expect(CustomerOrder.where(customer_id: customer_id).last).to have_attributes order_id: order_id
        end

        include_context 'notifications'
      end

      context 'first time the customer makes an order for that catalog' do
        before { CustomerOrder.where(customer_id: customer_id).delete_all }

        before { create :customer_order, customer_id: customer_id, store: create(:store) }

        before { expect(api_mock).to receive(:create_order).with(create_order_params).and_return(flowhub_order) }

        it 'respond with created order' do
          post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store, as_json: true), params: params.to_json

          expect(json).to have_key 'order'
          expect(json['order']).to eq order_response
        end

        it 'track new order' do
          expect do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
          end.to change {
            CustomerOrder.where(customer_id: customer_id).count
          }.by 1

          expect(CustomerOrder.where(customer_id: customer_id).last).to have_attributes order_id: order_id, store_id: kiosk.store_id
        end
      end

      context 'second time existing previuos order, the customer makes an order' do
        let!(:customer_order) { create :customer_order, customer_id: customer_id, order_id: order_id, store: kiosk.store }

        before { expect(api_mock).to receive(:create_order).with(create_order_params).and_return(flowhub_order(order_id: '1')) }

        it 'respond with new order' do
          post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store, as_json: true), params: params.to_json

          expect(json).to have_key 'order'
          expect(json['order']).to eq order_response(order_id: '1')
        end

        it 'track new order' do
          expect do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
          end.to change {
            CustomerOrder.where(customer_id: customer_id).count
          }.by 1

          expect(CustomerOrder.where(customer_id: customer_id).last).to have_attributes order_id: '1', store_id: kiosk.store_id
        end

        include_context 'notifications'
      end

      include_examples 'validate params'

      include_examples 'catch unexpected errors', error: Flowhub::FlowhubError.new('some error')

      def order_response(options = {})
        to_peak_order(flowhub_order(options), order_params).as_json
      end
    end
  end

  describe 'catalog with leaflogix integration' do
    include LeaflogixApiHelper

    let(:store) { create :leaflogix_store }
    let(:api_mock) { double(:leaflogix_api_client) }

    before do
      allow(Leaflogix::ApiClient).to receive(:new).with(store.leaflogix_api_config).and_return api_mock
      allow(api_mock).to receive(:get_customer).with(leaflogix_customer[:customerId]).and_return leaflogix_customer
    end

    describe 'create' do
      let(:order_params) { leaflogix_create_order_params(product) }
      let(:params) { { order: order_params.merge(other: 'value') } }
      let(:create_order_params) { { data: to_save_order_payload(order_params) } }
      let(:order_id) { leaflogix_order[:orderId] }
      let(:customer_id) { leaflogix_customer['customerId'] }

      context 'first time the customer makes an order' do
        before { CustomerOrder.where(customer_id: leaflogix_order[:customerId]).delete_all }

        before { expect(api_mock).to receive(:create_order).with(create_order_params).and_return(leaflogix_order) }

        it 'respond with created order' do
          post api_v1_catalogs_orders_path(kiosk.id), params: params.to_json, headers: auth_headers(store, as_json: true)

          expect(json).to have_key 'order'
          expect(json['order']).to eq order_response
        end

        it 'track new order' do
          expect do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
          end.to change {
            CustomerOrder.where(customer_id: customer_id).count
          }.by 1

          expect(CustomerOrder.where(customer_id: customer_id).last).to have_attributes order_id: order_id
        end

        include_context 'notifications'
      end

      context 'first time the customer makes an order for that catalog' do
        before { CustomerOrder.where(customer_id: customer_id).delete_all }

        before { create :customer_order, customer_id: customer_id, store: create(:store) }

        before { expect(api_mock).to receive(:create_order).with(create_order_params).and_return(leaflogix_order) }

        it 'respond with created order' do
          post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store, as_json: true), params: params.to_json

          expect(json).to have_key 'order'
          expect(json['order']).to eq order_response
        end

        it 'track new order' do
          expect do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
          end.to change {
            CustomerOrder.where(customer_id: customer_id).count
          }.by 1

          expect(CustomerOrder.where(customer_id: customer_id).last).to have_attributes order_id: order_id, store_id: kiosk.store_id
        end
      end

      context 'second time existing previuos order, the customer makes an order' do
        let!(:customer_order) { create :customer_order, customer_id: customer_id, order_id: order_id, store: kiosk.store }

        before { expect(api_mock).to receive(:create_order).with(create_order_params).and_return(leaflogix_order(order_id: '1')) }

        it 'respond with new order' do
          post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store, as_json: true), params: params.to_json

          expect(json).to have_key 'order'
          expect(json['order']).to eq order_response(order_id: '1')
        end

        it 'track new order' do
          expect do
            post api_v1_catalogs_orders_path(kiosk.id), headers: auth_headers(store), params: params
          end.to change {
            CustomerOrder.where(customer_id: customer_id).count
          }.by 1

          expect(CustomerOrder.where(customer_id: customer_id).last).to have_attributes order_id: '1', store_id: kiosk.store_id
        end

        include_context 'notifications'
      end

      include_examples 'validate params'

      include_examples 'catch unexpected errors', error: Leaflogix::LeaflogixError.new('some error')

      def order_response(options = {})
        to_peak_order(leaflogix_order(options), order_params).as_json
      end
    end
  end
end
