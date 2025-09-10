require 'rails_helper'

describe Store do
  let(:store) { build_stubbed :store, api_type: nil }

  it 'is valid' do
    expect(store).to be_valid
  end

  it 'is active' do
    expect(store).to be_active
  end

  it 'is valid without client' do
    store.client = nil
    expect(store).to be_valid
  end

  it 'is not valid without name' do
    store.name = nil
    expect(store).not_to be_valid
  end

  it 'if notifications enabled, require recipients, title and customer intro' do
    store.notifications_enabled = true

    expect(store).not_to be_valid
    expect(store.errors[:notifications_recipients]).to eq ["can't be blank"]
    expect(store.errors[:notifications_title]).to eq ["can't be blank"]
    expect(store.errors[:notifications_intro]).to eq ["can't be blank"]
  end

  it 'if notifications are disabled, do not require recipients and title' do
    store.notifications_enabled = false

    expect(store).to be_valid
  end

  it 'if notifications is not configured, do not require recipients and title' do
    store.notification_settings = nil

    expect(store).to be_valid
  end

  it 'current sync' do
    store.store_syncs.build
    current = store.store_syncs.build

    expect(store.current_sync).to be
    expect(store.current_sync).to eq current
  end

  it 'is valid without api settings' do
    store.api_settings = {}

    expect(store).to be_valid
  end

  context 'notification settings for treez' do
    let(:store) { build_stubbed :treez_store }

    it 'if notifications are disabled, do not require recipients and title' do
      store.notifications_enabled = false
      store.notifications_send_to_customer = true

      expect(store).to be_valid

      expect(store.notifications_enabled).not_to be
      expect(store.notifications_send_to_customer).not_to be
    end
  end

  context 'api_settings for treez' do
    let(:store) { build_stubbed :treez_store }

    it 'only know sync types are valid' do
      expect(store).to be_valid

      store.api_type = nil
      expect(store).to be_valid

      store.api_type = 'other'
      expect(store).not_to be_valid
    end

    it 'require dispensary name' do
      store.dispensary_name = '  '

      expect(store).not_to be_valid
      expect(store.errors[:dispensary_name]).to eq ["can't be blank"]
    end

    it 'require api key' do
      store.api_key = '  '

      expect(store).not_to be_valid
      expect(store.errors[:api_key]).to eq ["can't be blank"]
    end

    it 'sync_frequency' do
      store.dispensary_name = 'xxx'
      store.sync_frequency = nil

      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency]).to eq ["can't be blank"]

      store.sync_frequency = 0
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency]).to eq ['must be greater than 0']
    end

    it 'sync_frequency_offset' do
      store.sync_frequency_offset = nil

      expect(store).to be_valid

      store.sync_frequency_offset = 'xxx'
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency_offset]).to eq ['is not a number']

      store.sync_frequency_offset = -1
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency_offset]).to eq ['must be greater than or equal to 0']

      store.sync_frequency_offset = 0.5
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency_offset]).to eq ['must be an integer']
    end
  end

  context 'api_settings for headset' do
    let(:store) { build_stubbed :headset_store }

    it 'is valid' do
      expect(store).to be_valid
    end

    it 'sync_frequency' do
      store.sync_frequency = 0
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency]).to eq ['must be greater than 0']
    end

    it 'sync_frequency_offset' do
      store.sync_frequency_offset = nil

      expect(store).to be_valid

      store.sync_frequency_offset = 'xxx'
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency_offset]).to eq ['is not a number']

      store.sync_frequency_offset = -1
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency_offset]).to eq ['must be greater than or equal to 0']

      store.sync_frequency_offset = 0.5
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency_offset]).to eq ['must be an integer']
    end

    it 'require api key' do
      store.api_key = '  '

      expect(store).not_to be_valid
      expect(store.errors[:api_key]).to eq ["can't be blank"]
    end

    it 'require store id' do
      store.api_store_id = '  '

      expect(store).not_to be_valid
      expect(store.errors[:api_store_id]).to eq ["can't be blank"]
    end
  end

  context 'api_settings for flowhub' do
    let(:store) { build_stubbed :flowhub_store }

    it 'is valid' do
      expect(store).to be_valid
    end

    it 'sync_frequency' do
      store.sync_frequency = 0
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency]).to eq ['must be greater than 0']
    end

    it 'sync_frequency_offset' do
      store.sync_frequency_offset = nil

      expect(store).to be_valid

      store.sync_frequency_offset = 'xxx'
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency_offset]).to eq ['is not a number']

      store.sync_frequency_offset = -1
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency_offset]).to eq ['must be greater than or equal to 0']

      store.sync_frequency_offset = 0.5
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency_offset]).to eq ['must be an integer']
    end

    it 'require api key' do
      store.api_key = '  '

      expect(store).not_to be_valid
      expect(store.errors[:api_key]).to eq ["can't be blank"]
    end

    it 'require location id' do
      store.location_id = '  '

      expect(store).not_to be_valid
      expect(store.errors[:location_id]).to eq ["can't be blank"]
    end

    it 'require auth0_client_id' do
      store.auth0_client_id = '  '

      expect(store).not_to be_valid
      expect(store.errors[:auth0_client_id]).to eq ["can't be blank"]
    end

    it 'require auth0_client_secret' do
      store.auth0_client_secret = '  '

      expect(store).not_to be_valid
      expect(store.errors[:auth0_client_secret]).to eq ["can't be blank"]
    end

    it 'only know customer types are valid' do
      expect(store).to be_valid

      store.customer_type_filter = nil
      expect(store).to be_valid

      %w[recCustomer medCustomer].each do |type|
        store.customer_type_filter = type
        expect(store).to be_valid
      end

      store.customer_type_filter = 'other'
      expect(store).not_to be_valid
    end
  end

  context 'api_settings for leaflogix' do
    let(:store) { build_stubbed :leaflogix_store }

    it 'is valid' do
      expect(store).to be_valid
    end

    it 'sync_frequency' do
      store.sync_frequency = 0
      expect(store).not_to be_valid
      expect(store.errors[:sync_frequency]).to eq ['must be greater than 0']
    end

    it 'require api key' do
      store.api_key = '  '

      expect(store).not_to be_valid
      expect(store.errors[:api_key]).to eq ["can't be blank"]
    end
  end

  context 'token payload' do
    let(:store) { create :store }
    let(:kiosk) { create :kiosk, store: store }

    it 'include information' do
      expect(store.to_token_payload).to eq(sub: store.id, aud: [:api], jti: store.jti)
    end
  end

  describe 'name' do
    let!(:store) { create :store }
    let!(:other_client) { create :client }

    it 'should not be unique' do
      another_store = build :store, name: store.name, client: other_client

      expect(another_store).to be_valid
    end

    it 'should be unique by client' do
      another_store = build :store, name: store.name, client: store.client

      expect(another_store).not_to be_valid
      expect(another_store.errors[:name]).to eq ['has already been taken']
    end
  end

  context 'product parser' do
    let(:store) { build_stubbed :store }

    it 'return nothing by default' do
      expect(store.api_parser).not_to be
      expect(store.csv_parser('csv_file')).to be_a ProductCSVParser
    end

    it 'return treez parser if configured' do
      store.api_type = 'treez'
      expect(store.api_parser).to be_a TreezApiParser
      expect(store.csv_parser('csv_file')).to be_a ProductCSVParser
    end

    it 'return headset parser if configured' do
      store.api_type = 'headset'
      expect(store.api_parser).to be_a HeadsetApiParser
      expect(store.csv_parser('csv_file')).to be_a ProductCSVParser
    end
  end

  context 'store sync' do
    let(:store) { build :treez_store, dispensary_name: 'xxx', sync_frequency: 6 }

    it 'creates sync cron job for active store' do
      expect do
        store.save!
      end.to change {
        Sidekiq::Cron::Job.count
      }.by 1

      expect(job).to be
    end

    it 'cron job using frequency & offset' do
      store.save!

      expect(job).to have_attributes cron: '*/6 * * * *'

      store.update!(sync_frequency_offset: 2)

      expect(job).to have_attributes cron: '2-59/6 * * * *'

      store.update!(sync_frequency_offset: '')

      expect(job).to have_attributes cron: '*/6 * * * *'
    end

    it 'stop sync when store change api_type to nil' do
      store.save!

      expect do
        store.update!(api_type: nil)
      end.to change {
        Sidekiq::Cron::Job.count
      }.by -1

      expect(job).not_to be
    end

    it 'stop sync when store change sync_frequency to nil' do
      store.save!

      expect do
        store.update!(api_type: nil, sync_frequency: nil)
      end.to change {
        Sidekiq::Cron::Job.count
      }.by -1

      expect(job).not_to be
    end

    it 'stop sync when store is disabled' do
      store.save!

      expect do
        store.update!(active: false)
      end.to change {
        Sidekiq::Cron::Job.count
      }.by -1

      expect(job).not_to be
    end

    def job
      Sidekiq::Cron::Job.find("catalog_sync_#{store.id}")
    end
  end

  context '#from_token_payload' do
    let(:store) { create :store, regenerate_jti: true }

    it 'return store when active' do
      st = Store.from_token_payload('sub' => store.id, 'aud' => ['api'], 'jti' => store.jti)
      expect(st).to be
      expect(st).to eq store
    end

    it 'raise when inactive' do
      store.update!(active: false)

      expect  do
        Store.from_token_payload('sub' => store.id, 'aud' => ['api'], 'jti' => store.jti)
      end.to raise_error(/ActiveRecord::RecordNotFound/)
    end

    it 'raise with invalid jti' do
      expect  do
        Store.from_token_payload('sub' => store.id, 'aud' => ['api'], 'jti' => 'invalid')
      end.to raise_error(/ActiveRecord::RecordNotFound/)
    end

    it 'raise with nil jti on payload' do
      expect  do
        Store.from_token_payload('sub' => store.id, 'aud' => ['api'], 'jti' => nil)
      end.to raise_error(/ActiveRecord::RecordNotFound/)
    end

    it 'raise with nil jti' do
      store.update!(jti: nil)

      expect  do
        Store.from_token_payload('sub' => store.id, 'aud' => ['api'], 'jti' => nil)
      end.to raise_error(/ActiveRecord::RecordNotFound/)
    end
  end

  context 'generates jti after save' do
    let(:store) { build :store, regenerate_jti: true }

    it 'generates jti' do
      expect do
        store.save
      end.to change {
        store.jti
      }.from(nil).to(String)

      expect(store.jti.length).to be > 10
    end

    it "don't change jti after update" do
      store.save!

      expect do
        store.regenerate_jti = false
        store.update(name: 'a new name')
      end.not_to change {
        store.jti
      }
    end

    it 'change jti after update if requested' do
      store.save!

      expect do
        store.regenerate_jti = true
        store.update(name: 'a new name')
      end.to change {
        store.jti
      }
    end
  end
end
