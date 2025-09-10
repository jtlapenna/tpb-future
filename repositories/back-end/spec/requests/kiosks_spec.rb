require 'rails_helper'

describe 'Kiosks API' do
  include SerializationHelper::Stores

  let(:user) { create :user }
  let(:user_client) { create :user, client: client }

  def kiosk_json(kiosk, full: true)
    includes = {
      store: { only: %i[id name] }
    }

    methods = %i[
      tag_list sensor_method sensor_threshold
      product_filter_criteria product_filter_value_type product_filter_value_id product_layout_id
    ]

    attributes = %i[id name featured_mode]

    c_json = kiosk.as_json(only: attributes, include: includes, methods: methods).merge(
      'layout' => layout_json(kiosk.layout)
    )

    c_json['tag_list'] = c_json['tag_list'].to_a.sort!

    c_json
  end

  context '#index as admin' do
    let(:kiosks) { Kiosk.all.order(id: :desc) }
    let(:expected_kiosks) { kiosks.map { |c| kiosk_json(c) } }

    before do
      create_list :kiosk, 3
      get kiosks_path, headers: auth_headers(user)
    end

    it 'respond with kiosks' do
      expect(json).to have_key('kiosks')
      expect(json['kiosks'].count).to eq 3
      expect(json['kiosks']).to match_kiosks expected_kiosks
    end
  end

  context '#index as client' do
    let(:expected_kiosk) { kiosk_json(Kiosk.last, full: false) }
    let (:client) { Kiosk.last.store.client }

    before do
      create_list :kiosk, 3
      get kiosks_path, headers: auth_headers(user_client)
    end

    it 'respond with kiosks' do
      expect(json).to have_key('kiosks')
      expect(json['kiosks'].count).to eq 1
      expect(json['kiosks'].first).to match_kiosk expected_kiosk
    end
  end

  context '#index#sort' do
    let!(:kiosks) do
      [
        create(:kiosk, name: 'Kiosk 3'),
        create(:kiosk, name: 'Kiosk 1'),
        create(:kiosk, name: 'Kiosk 2')
      ].sort_by(&:name)
    end
    let(:expected_kiosks) { kiosks.map { |c| kiosk_json(c) } }

    before do
      get kiosks_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted kiosks' do
      expect(json).to have_key('kiosks')
      expect(json['kiosks'].count).to eq 3
      expect(json['kiosks']).to match_kiosks expected_kiosks
    end
  end

  it_behaves_like 'paginated resource', Kiosk

  context '#create' do
    let(:store) { create :store }
    let(:kiosk) { Kiosk.last }
    let(:params) do
      { kiosk:
        { name: 'Kiosk 1',
          store_id: store.id,
          tag_list: 'tag 2, tag 1',
          sensor_method: 'us',
          sensor_threshold: 721 } }
    end
    let(:missing_name_params) { { kiosk: { active: false } } }

    it 'create Kiosk' do
      expect do
        post kiosks_path, params: params, headers: auth_headers(user)
      end.to change {
        Kiosk.count
      }.by 1
    end

    it 'created kiosk values' do
      post kiosks_path, params: params.to_json, headers: auth_headers(user, as_json: true)

      expect(kiosk).to be
      expect(kiosk.name).to eq 'Kiosk 1'
      # expect(kiosk.products_tags.count).to eq 2
      expect(kiosk.tag_list).to match_array ['tag 1', 'tag 2']
      expect(kiosk.sensor_method).to eq 'us'
      expect(kiosk.sensor_threshold).to eq 721
    end

    it 'respond with kiosk' do
      post kiosks_path, params: params, headers: auth_headers(user)

      json['kiosk']['tag_list'].sort!
      expect(json).to have_key('kiosk')
      expect(json['kiosk']).to eq kiosk_json(kiosk)
    end

    it 'return errors' do
      post kiosks_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('store' => ['must exist'], 'name' => ["can't be blank"])
    end
  end

  context '#clone' do
    let(:params) { { id: kiosk.id } }
    let(:kiosk) { create :kiosk, name: 'kiosk' }
    let(:missing_id_param) { { id: 'xxx' } }

    it 'return cloned kiosk' do
      post clone_kiosk_path(params), headers: auth_headers(user)
      expect(json).to have_key('kiosk')
      expect(json['kiosk']).to eq kiosk_json(Kiosk.last)
    end

    it 'return errors' do
      post clone_kiosk_path(missing_id_param), headers: auth_headers(user)

      expect(json).to have_key('error')
      expect(json['error']).to have_key('message')
      expect(json['error']['message']).to match(/not found/)
    end
  end

  context '#update' do
    let(:params) { { id: kiosk.id, kiosk: { name: 'new name' } } }
    let(:kiosk) { create :kiosk, name: 'kiosk' }
    let(:missing_name_params) { { kiosk: { name: '' } } }

    it 'update kiosk' do
      put kiosk_path(kiosk), params: params, headers: auth_headers(user)

      expect(kiosk.reload.name).to eq 'new name'
    end

    it 'return updated kiosk' do
      put kiosk_path(kiosk), params: params, headers: auth_headers(user)

      expect(json).to have_key('kiosk')
      expect(json['kiosk']).to match_kiosk kiosk_json(kiosk.reload)
    end

    it 'return errors' do
      put kiosk_path(kiosk), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end

    context 'with rfids products' do
      let(:kiosk) { create :kiosk }
      let(:category) { create :store_category, store: kiosk.store }
      let(:kiosk_product1) { create :kiosk_product, kiosk: kiosk }
      let(:kiosk_product2) { create :kiosk_product, kiosk: kiosk }
      let(:kiosk_product3) { create :kiosk_product, kiosk: kiosk }
      let(:kiosk_product4) { create :kiosk_product, kiosk: kiosk }
      let(:existing) { create :rfid_product, rfid_entity: kiosk_product3 }
      let(:existing2) { create :rfid_product, rfid_entity: kiosk_product4 }
      let(:params) do
        { id: kiosk.id, kiosk: {
          rfid_products_attributes: [
              { rfid: '123', rfid_entity: kiosk_product1 },
              { rfid: '1234', rfid_entity: kiosk_product2 },
              { rfid: '12345', rfid_entity: nil },
              { id: existing.id, rfid_entity: kiosk_product3, _destroy: true }
          ]
        } }
      end

      before { existing.touch; existing2.touch }

      it 'create rfids' do
        expect do
          put kiosk_path(kiosk), params: params, headers: auth_headers(user)
        end.to change {
          kiosk.rfid_products.count
        }.from(2).to 4
      end

      it 'rfids' do
        put kiosk_path(kiosk), params: params, headers: auth_headers(user)

        expect(kiosk.reload.rfid_products.map(&:rfid)).to match_array ['123', '1234', '12345', existing2.rfid]
      end
    end
  end

  context '#show' do
    let(:params) { { id: kiosk.id } }
    let(:kiosk) { create :kiosk, name: 'Kiosk' }
    let (:client) { Kiosk.last.store.client }

    it 'return kiosk' do
      get kiosk_path(kiosk), params: params, headers: auth_headers(user)

      expect(json).to have_key('kiosk')
      expect(json['kiosk']).to eq(kiosk_json(kiosk))
    end

    it 'as non-admin dont show api type and key' do
      get kiosk_path(kiosk), params: params, headers: auth_headers(user_client)

      expect(json).to have_key('kiosk')
      expect(json['kiosk']).not_to have_key('api_client_id')
      expect(json['kiosk']).not_to have_key('api_key')
    end
  end
end
