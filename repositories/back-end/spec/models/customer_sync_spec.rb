require 'rails_helper'

describe CustomerSync do
  include LeaflogixApiHelper

  let(:api_key) { 'xz123' }
  let(:store) { create :leaflogix_store, api_key: api_key }
  let(:sync) { build_stubbed :customer_sync, store: store, external_account_id: store.api_key }
  let(:customer_sync) { create :customer_sync, store: store, external_account_id: store.api_key }

  it 'is valid' do
    expect(sync).to be_valid
  end

  it 'is pending' do
    expect(sync).to be_pending
  end

  it 'is not valid without store' do
    sync.store = nil
    expect(sync).not_to be_valid
    expect(sync.errors[:store]).to eq ['must exist']
  end

  context '#do_process' do
    let(:customers) { leaflogix_customers.map(&:deep_symbolize_keys) }
    let(:api_mock) { instance_double(Leaflogix::ApiClient) }
    let(:last_finished_sync) { 3.days.ago.change(usec: 0) }

    before do
      create :customer_sync, created_at: last_finished_sync, store: customer_sync.store, external_account_id: customer_sync.store.api_key, status: :finished

      allow(api_mock).to receive(:customers).with(last_finished_sync).and_return(customers)
      allow(customer_sync).to receive(:api_client).and_return(api_mock)
    end

    it '3 customers created' do
      expect { customer_sync.do_process }.to change { Customer.count }.by 3
    end

    it 'assign account id to all customers' do
      customer_sync.do_process

      expect(Customer.distinct.pluck(:external_account_id)).to eq [api_key]
    end

    it 'do not update customers from other accounts' do
      leaflogix_customer = customers.first

      first_name = "#{leaflogix_customer[:name]}x"

      customer = create :customer, customer_id: leaflogix_customer[:customerId], store_id: store.id, external_account_id: "#{api_key}1", first_name: first_name

      expect { customer_sync.do_process }.not_to change { customer.reload.first_name }
      expect(Customer.count).to eq 4
    end

    context 'worked' do
      before do
        customers[0..1].each { |customer| build_stubbed :customer, customer_id: customer['customerId'] }
        customer_sync.do_process
      end

      it 'a customer created and 2 edited' do
        expect(Customer.count).to eq 3
      end

      it 'information mapped correctly' do
        Customer.all.each_with_index do |customer, index|
          first_name, last_name = customers[index][:name].to_s.split(' ', 2)

          expect(customer.customer_id).to eq customers[index][:customerId].to_s
          expect(customer.birthday).to eq customers[index][:dateOfBirth]
          expect(customer.drivers_license).to eq customers[index][:driversLicenseHash]
          expect(customer.email).to eq customers[index][:emailAddress]
          expect(customer.first_name).to eq first_name
          expect(customer.last_name).to eq last_name
          expect(customer.gender).to eq nil
          expect(customer.notes).to eq nil
          expect(customer.phone).to eq customers[index][:phone]
          expect(customer.status).to eq customers[index][:status]
        end
      end

      it 'customer sync finished' do
        expect(customer_sync.status).to eq 'finished'
      end
    end

    context 'Customer fail' do
      let(:customers) { leaflogix_customers.map(&:deep_symbolize_keys).insert(1, customerId: '') }

      it 'Ignore error and continue' do
        expect(api_mock.customers(last_finished_sync).count).to eq 4
        expect { customer_sync.do_process }.to change { Customer.count }.by 3
      end

      it 'customer sync failed' do
        customer_sync.do_process
        expect(customer_sync.status).to eq 'failed'
      end
    end
  end
end
