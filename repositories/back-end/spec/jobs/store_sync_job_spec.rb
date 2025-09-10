require 'rails_helper'

describe StoreSyncJob do
  let(:catalog) { create :catalog, store: store }
  let(:store) { create :treez_store, dispensary_name: 'xxx' }
  let(:job) { StoreSyncJob.new }

  context 'without pending syncs' do
    let(:parser) { double }

    before do
      allow(Store).to receive(:find).and_return store
      expect(parser).to receive(:parse).and_return(parse_result)
    end

    context 'when api respond ok' do
      let(:sync) { double(process_items: nil) }
      let(:parse_result) { { errors: nil, sync: sync } }

      before do
        category = store.store_categories.first
        create :store_product, store_category: category, stock: 10, sku: '123'
        create :store_product, store_category: category, stock: 5, sku: '1234'
        automatched = create :store_product, store_category: category, stock: 7, sku: '12345'

        expect(store).to receive(:api_parser).and_return(parser)
        expect(sync).to receive(:process_items)
        expect(sync).to receive(:reload).and_return(sync)

        items = double(auto_matched: double(map: [automatched.id]))
        expect(sync).to receive(:store_sync_items).and_return(items)
      end

      it 'call to store parser' do
        job.perform(store.id)
      end

      it 'non matched products with stock are updated with stock 0' do
        expect do
          job.perform(store.id)
        end.to change {
          store.reload.store_products.where(sku: %w[123 1234]).map(&:stock).sum
        }.from(15).to 0
      end

      it 'non matched products with stock are touched' do
        expect do
          job.perform(store.id)
        end.to change {
          store.reload.store_products.where(sku: %w[123 1234]).pluck(:updated_at)
        }
      end

      it 'non matched products without stock are not touched' do
        store.store_products.where(sku: '123').update_all(stock: 0)

        old_dates = store.reload.store_products.where(sku: %w[123 1234]).order(:sku).pluck(:updated_at)

        Timecop.travel(1.hour.from_now) { job.perform(store.id) }

        new_dates = store.reload.store_products.where(sku: %w[123 1234]).order(:sku).pluck(:updated_at)

        expect(new_dates[0]).to eq old_dates[0]
        expect(new_dates[1]).not_to eq old_dates[1]
      end

      it 'matched products have stock' do
        expect do
          job.perform(store.id)
        end.not_to change {
          store.reload.store_products.where(sku: ['12345']).map(&:stock).sum
        }
      end
    end

    context 'when api respond with error' do
      let(:parse_result) { { errors: [{}], sync: nil } }

      it 'call to store parser' do
        expect(store).to receive(:api_parser).and_return(parser)

        job.perform(store.id)
      end

      it 'notify by email' do
        expect(store).to receive(:api_parser).and_return(parser)

        expect do
          job.perform(store.id)
        end.to have_enqueued_job.with('ApiSyncMailer', 'sync_error', 'deliver_now', args: [store.id, errors: anything])
      end
    end
  end

  context 'when service is not available' do
    let(:parser) { double }

    before do
      expect(Store).to receive(:find).and_return store
      expect(store).to receive(:api_parser).and_return(parser)
      expect(parser).to receive(:parse).and_raise(Errors::ServiceUnavailable)
    end

    it 'notify by email by default' do
      expect do
        job.perform(store.id)
      end.to have_enqueued_job.with('ApiSyncMailer', 'sync_error', 'deliver_now', args: [store.id, exception: anything])
    end

    it 'skip notification by email when env is set' do
      ENV['STORE_SYNC_SKIP_SERVICE_UNAVAILABLE_NOTIFICATION'] = 'true'

      expect do
        job.perform(store.id)
      end.not_to have_enqueued_job.with('ApiSyncMailer', 'sync_error', 'deliver_now', args: [store.id, exception: anything])
    end
  end

  context "when api don't respond" do
    let(:parser) { double }

    before do
      expect(Store).to receive(:find).and_return store
      expect(store).to receive(:api_parser).and_return(parser)
      expect(parser).to receive(:parse).and_raise('error')
    end

    it 'notify by email' do
      expect do
        job.perform(store.id)
      end.to have_enqueued_job.with('ApiSyncMailer', 'sync_error', 'deliver_now', args: [store.id, exception: anything])
    end
  end

  context 'with previous syncs in progress' do
    let(:url) { 'https://api.treez.io/v1.0/dispensary/xxx/menu/product_list?limit=500&offset=0&stock=all&type=all' }

    before do
      store.store_syncs.create!(status: :in_progress)
      store.store_syncs.create!(status: :pending)
      store.reload

      stub_request(:post, 'https://api.treez.io/v1.0/dispensary/xxx/config/api/gettokens').with(
        body: "apikey=#{store.api_key}&client_id=#{store.api_client_id}",
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8' }
      ).to_return(
        status: 200,
        body: { access_token: 'token', resultCode: 'SUCCESS' }.to_json,
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )

      stub_request(:get, url).with(
        headers: { 'Authorization' => 'bearer token', 'client-Id' => store.api_client_id }
      ).to_return(
        body: api_response.to_json,
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
    end

    it 'finish all pending syncs' do
      expect do
        job.perform(store.id)
      end.to change {
        store.store_syncs.finished.count
      }.from(0).to 3
    end
  end

  def api_response
    {
      "page_count": 0,
      "total_count": 0,
      "product_list": []
    }
  end
end
