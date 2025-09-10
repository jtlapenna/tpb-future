require 'rails_helper'

describe 'Stores API' do
  include SerializationHelper::Stores

  let(:user) { create :user }
  let(:user_client) { create :user, client: client }

  def store_json(store, full: true)
    includes = {}

    methods = %i[
      featured_mode enabled_share_email_product enabled_share_sms_product
      notifications_enabled notifications_send_to_customer
      notifications_recipients notifications_title notifications_intro
    ]

    if full
      methods += %i[
        api_automatch api_version api_type api_autopublish dispensary_name
        override_on_sync sync_frequency sync_frequency_offset
        api_client_id api_key api_store_id sync_tags location_id
        auth0_client_id auth0_client_secret customer_type_filter
      ]
    end

    attributes = %i[id name]

    s_json = store.as_json(only: attributes, include: includes, methods: methods).merge(
      'logo' => asset_json(store.logo),
      'settings' => settings_json(store.settings, full: full),
      'client' => client_json(store.client)
    )

    s_json['current_sync_id'] = store.current_sync ? store.current_sync.id : nil
    s_json['store_categories'] = store.store_categories
                                      .order(StoreCategory.arel_table['name'].lower.asc).as_json(only: %i[id name order store_id])

    s_json
  end

  context '#index as admin' do
    let(:stores) { Store.all.order(id: :desc) }
    let(:expected_stores) { stores.map { |c| store_json(c) } }

    before do
      create_list :store, 3
      get stores_path, headers: auth_headers(user)
    end

    it 'respond with stores' do
      expect(json).to have_key('stores')
      expect(json['stores'].count).to eq 3
      expect(json['stores']).to match_stores expected_stores
    end
  end

  context '#index as client' do
    let(:expected_store) { store_json(Store.last, full: false) }
    let (:client) { Store.last.client }

    before do
      create_list :store, 3
      get stores_path, headers: auth_headers(user_client)
    end

    it 'respond with stores' do
      expect(json).to have_key('stores')
      expect(json['stores'].count).to eq 1
      expect(json['stores'].first).to match_store expected_store
    end
  end

  context '#index#sort' do
    let(:stores) { Store.all.order(name: :asc) }
    let(:expected_stores) { stores.map { |c| store_json(c) } }

    before do
      create :store, name: 'Store 3'
      create :store, name: 'Store 1'
      create :store, name: 'Store 2'
      get stores_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted stores' do
      expect(json).to have_key('stores')
      expect(json['stores'].count).to eq 3
      expect(json['stores']).to match_stores expected_stores
    end
  end

  it_behaves_like 'paginated resource', Store

  context '#create' do
    let(:client) { create :client }
    let(:store) { Store.last }
    let(:settings_attributes) do
      {
        admin_email: 'admin_email (string)',
        printer_location: 'printer_location (string)',
        pos_location: 'pos_location (string)',
        main_color: 'main_color (hexadecimal)',
        secondary_color: 'secondary_color ( hexadecimal) ',
        background_media_attributes: { url: 'background_media (url)' },
        featured_products_on_top_for_brands_page: 'featured... for brands (bool)',
        featured_products_on_top_for_effects_and_uses_page: 'featured... for effects and uses (bool)',
        featured_products_on_top_for_products_page: 'featured... for productos (bool)',
        idle_delay: 'idle_delay (seconds)',
        restart_delay: 'restart_delay (seconds)',
        service_worker_log: 'service_worker_log (bool)',
        default_product_description: 'default_product_description (text)',
        heap_id: 'heap_id( string )',
        dispensary_license_number: 123,
        disable_tax_message: 'disable_tax_message (bool)'
      }
    end
    let(:params) do
      { store:
        {
          name: 'Store 1',
          client_id: client.id,
          layout: 'shopping',
          settings_attributes: settings_attributes,

          api_type: 'treez',
          api_key: 'xxx',
          api_automatch: true,
          override_on_sync: true,
          dispensary_name: 'xxx',
          sync_frequency: 1,
          api_client_id: 'yyy',
          location_id: 'lll',
          auth0_client_id: 'c0',
          auth0_client_secret: 's0',
          customer_type_filter: 'medCustomer',
          notifications_enabled: true,
          notifications_title: 'notifications title',
          notifications_recipients: ['a@a.com', 'b@b.com'],
          notifications_intro: 'Hi, customer!',
          notifications_send_to_customer: false,

          logo_attributes: {
            url: 'logo (url)'
          }
        } }
    end
    let(:missing_name_params) { { store: { active: false, client_id: client.id, layout: 'shopping' } } }

    it 'create Store' do
      expect do
        post stores_path, params: params, headers: auth_headers(user)
      end.to change {
        Store.count
      }.by 1
    end

    it 'created store' do
      post stores_path, params: params.to_json, headers: auth_headers(user, as_json: true)

      expect(store.name).to eq 'Store 1'
      expect(store.client_id).to eq client.id
      expect(store.jti).to be_a(String)
      expect(store.jti.length).to be > 10
      expect(store.logo).to have_attributes url: 'logo (url)'
      expect(store.settings).to have_attributes settings_attributes.except(:background_media_attributes)
      expect(store.settings.background_media).to have_attributes url: 'background_media (url)'

      expect(store.api_type).to eq 'treez'
      expect(store.api_key).to eq 'xxx'
      expect(store.api_automatch).to eq true
      expect(store.override_on_sync).to eq true
      expect(store.sync_frequency).to eq 1
      expect(store.dispensary_name).to eq 'xxx'
      expect(store.api_client_id).to eq 'yyy'
      expect(store.location_id).to eq 'lll'
      expect(store.auth0_client_id).to eq 'c0'
      expect(store.auth0_client_secret).to eq 's0'
      expect(store.notifications_enabled).to be
      expect(store.notifications_recipients).to eq ['a@a.com', 'b@b.com']
      expect(store.notifications_title).to eq 'notifications title'
      expect(store.notifications_intro).to eq 'Hi, customer!'
      expect(store.notifications_send_to_customer).to eq false
    end

    it 'create store with notifications enabled and sent mail to costumer' do
      params[:store][:notifications_send_to_customer] = true

      post stores_path, params: params.to_json, headers: auth_headers(user, as_json: true)

      expect(store.notifications_enabled).to eq true
      expect(store.notifications_send_to_customer).to eq true
    end

    it 'respond with Store' do
      post stores_path, params: params, headers: auth_headers(user)

      expect(json).to have_key('store')
      expect(json['store']).to eq store_json(store)
    end

    it 'return errors' do
      post stores_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:user) { create :user }
    let(:params) { { id: store.id, store: { name: 'new name', api_type: 'treez', dispensary_name: 'yyy', sync_frequency: 5, sync_frequency_offset: 1, api_key: 'xxx' } } }
    let(:store) { create :store, name: 'store' }
    let(:category) { create :store_category, store: store }
    let(:missing_name_params) { { store: { name: '' } } }

    it 'update store' do
      put store_path(store), params: params, headers: auth_headers(user)

      expect(store.reload.name).to eq 'new name'
      expect(store.reload.api_type).to eq 'treez'
      expect(store.reload.api_key).to eq 'xxx'
      expect(store.reload.sync_frequency).to eq '5'
      expect(store.reload.sync_frequency_offset).to eq '1'
      expect(store.reload.dispensary_name).to eq 'yyy'
    end

    it 'return updated Store' do
      put store_path(store), params: params, headers: auth_headers(user)

      expect(json).to have_key('store')
      expect(json['store']).to eq store_json(store.reload)
    end

    it 'return errors' do
      put store_path(store), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end

    context 'updating settings' do
      let(:params) { { id: store.id, store: { settings_attributes: new_settings_attributes.merge(id: settings.id) } } }
      let(:settings) { create :store_setting, data: settings_attributes }
      let(:store) { create :store, name: 'store', settings: settings }
      let(:settings_attributes) do
        {
          admin_email: 'admin_email (string)',
          printer_location: 'printer_location (string)',
          pos_location: 'pos_location (string)',
          main_color: 'main_color (hexadecimal)',
          secondary_color: 'secondary_color ( hexadecimal) ',
          featured_products_on_top_for_brands_page: 'featured... for brands (bool)',
          featured_products_on_top_for_effects_and_uses_page: 'featured... for effects and uses (bool)',
          featured_products_on_top_for_products_page: 'featured... for productos (bool)',
          idle_delay: 'idle_delay (seconds)',
          restart_delay: 'restart_delay (seconds)',
          service_worker_log: 'service_worker_log (bool)',
          default_product_description: 'default_product_description (text)',
          heap_id: 'heap_id( string )',
          dispensary_license_number: '123',
          disable_tax_message: 'disable_tax_message (bool)'
        }
      end
      let(:new_settings_attributes) do
        {
          admin_email: 'new email',
          printer_location: 'new printer_location',
          pos_location: 'new pos_location',
          main_color: 'new main_color',
          secondary_color: 'new secondary_color',
          featured_products_on_top_for_brands_page: 'new featured... for brands',
          featured_products_on_top_for_effects_and_uses_page: 'new featured... for effects and uses',
          featured_products_on_top_for_products_page: 'new featured... for productos',
          idle_delay: 'new idle_delay',
          restart_delay: 'new restart_delay',
          service_worker_log: 'new service_worker_log',
          default_product_description: 'new default_product_description',
          heap_id: 'new heap_id',
          dispensary_license_number: '12345',
          disable_tax_message: 'disable_tax_message',
          purchase_limits_attributes: [{
            name: 'limit name',
            limit: 24,
            store_category_ids: [category.id]
          }]
        }
      end

      it 'update attributes' do
        put store_path(store), params: params, headers: auth_headers(user)

        expect(settings.reload.data).to eq new_settings_attributes.except(:purchase_limits_attributes).stringify_keys
        expect(settings.purchase_limits.count).to eq 1
        expect(settings.purchase_limits.first).to have_attributes name: 'limit name', limit: 24, store_category_ids: [category.id]
      end
    end

    context '#update as client' do
      let(:params) { { id: store.id, store: { name: 'new name', api_type: 'treez', enabled_share_email_product: true, enabled_share_sms_product: true } } }
      let(:store) { create :store, name: 'store' }
      let (:client) { store.client }

      it 'update store' do
        put store_path(store), params: params, headers: auth_headers(user_client)

        expect(store.reload.name).to eq 'new name'
        expect(store.reload.api_type).to be_blank
        expect(store.reload.enabled_share_email_product).to be
        expect(store.reload.enabled_share_sms_product).to be
      end

      it 'return updated Store' do
        put store_path(store), params: params, headers: auth_headers(user_client)

        expect(json).to have_key('store')
        expect(json['store']).to eq store_json(store.reload, full: false)
      end
    end
  end

  context '#show' do
    let(:params) { { id: store.id } }
    let(:store) { create :store, name: 'Store' }

    before do
      # catalog.catalog_syncs.create
    end

    it 'return store' do
      get store_path(store), params: params, headers: auth_headers(user)

      expect(json).to have_key('store')
      expect(json['store']).to eq(store_json(store))
    end

    context 'with sync' do
      let(:sync) { create :store_sync, store: store }

      before { sync.touch }

      it 'return store with current sync' do
        get store_path(store), params: params, headers: auth_headers(user)

        expect(json).to have_key('store')
        expect(json['store']['current_sync_id']).to eq sync.id
      end

      it "don't return sync id when it is finished" do
        sync.finished!
        get store_path(store), params: params, headers: auth_headers(user)

        expect(json).to have_key('store')
        expect(json['store']).to have_key('current_sync_id')
        expect(json['store']['current_sync_id']).to be_nil
      end
    end
  end

  context '#show as client' do
    let(:params) { { id: store.id } }
    let(:store) { create :store, name: 'Store' }
    let (:client) { store.client }

    it 'return store' do
      get store_path(store), params: params, headers: auth_headers(user)

      expect(json).to have_key('store')
      expect(json['store']).to eq(store_json(store))
    end
  end

  context '#generate_token' do
    let(:store) { create :store }

    it 'respond with token' do
      current_token = store.jti

      post generate_token_store_path(store), headers: auth_headers(user)

      expect(json).to have_key 'jwt'

      token = json['jwt']
      expect(token.size).to be > 20
      expect(token.split('.').count).to eq 3
      expect(current_token).not_to eq store.reload.jti
    end

    it 'token payload' do
      post generate_token_store_path(store), headers: auth_headers(user)

      token = json['jwt']
      payload = Knock::AuthToken.new(token: token).payload
      expect(payload).to include('sub' => store.id, 'jti' => store.reload.jti, 'aud' => ['api'])
    end
  end
end
