require 'rails_helper'

describe CustomerSyncJob do
  include LeaflogixApiHelper

  let(:job) { CustomerSyncJob.new }
  let(:store) { create :leaflogix_store }

  let(:headers) { { 'Content-Type' => 'application/json; charset=utf-8' } }
  let(:api_response) { leaflogix_customers }
  let(:url) { 'https://leaflogix-publicapi.azurewebsites.net/customer/customers' }

  let(:url_auth) { 'https://leaflogix-publicapi.azurewebsites.net/util/AuthorizationHeader/xxxxx' }
  let(:auth_headers) { { 'Content-Type' => 'application/json', 'Authorization' => 'Basic token-value' } }
  let(:api_auth_response) { { status: 200, body: '"Basic token-value"', headers: headers } }

  before do
    stub_request(:get, url_auth).with(body: {}).to_return(api_auth_response)
    stub_request(:get, url).with(headers: auth_headers).to_return(body: api_response.to_json, headers: headers)
  end

  context 'without pending syncs' do
    context 'when api respond ok' do
      it 'create customers' do
        expect do
          job.perform(store.id)
        end.to change {
          Customer.count
        }.from(0).to 3
      end

      it 'create CustomerSync' do
        expect do
          job.perform(store.id)
        end.to change {
          CustomerSync.count
        }.from(0).to 1

        expect(CustomerSync.last).to have_attributes store: store, external_account_id: store.api_key
      end
    end
  end

  context 'with previous syncs in progress' do
    before do
      customer_sync = create(:customer_sync, store: store, external_account_id: store.api_key)
      customer_sync.in_progress!
    end

    it 'no create customers' do
      expect { job.perform(store.id) }.not_to change { Customer.count }
    end

    it 'can sync other store' do
      other_store = create(:store)
      other_store = create :leaflogix_store

      expect { CustomerSyncJob.new.perform(other_store.id) }.to change { CustomerSync.count }.from(1).to(2)
      expect(CustomerSync.last).to be_finished
    end
  end
end
