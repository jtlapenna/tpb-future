require 'rails_helper'

describe 'Clients API' do
  let(:user) { create :user }

  def client_json(client)
    client.as_json(only: %i[id name])
  end

  context '#index' do
    let(:clients) { Client.all.order(id: :desc) }
    let(:expected_clients) { clients.map { |c| client_json(c) } }

    before do
      create_list :client, 3
      get clients_path, headers: auth_headers(user)
    end

    it 'respond with clients' do
      expect(json).to have_key('clients')
      expect(json['clients'].count).to eq 3
      expect(json['clients']).to eq expected_clients
    end
  end

  context '#index#sort' do
    let(:clients) { Client.all.order(name: :asc) }
    let(:expected_clients) { clients.map { |c| client_json(c) } }

    before do
      create :client, name: 'Client 3'
      create :client, name: 'Client 1'
      create :client, name: 'Client 2'
      get clients_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted clients' do
      expect(json).to have_key('clients')
      expect(json['clients'].count).to eq 3
      expect(json['clients']).to eq expected_clients
    end
  end

  it_behaves_like 'paginated resource', Client

  context '#create' do
    let(:client) { Client.last }
    let(:params) { { client: { name: 'Client 1' } } }
    let(:missing_name_params) { { client: { active: false } } }

    it 'create Client' do
      expect do
        post clients_path, params: params, headers: auth_headers(user)
      end.to change {
        Client.count
      }.by 1
    end

    it 'respond with Client' do
      post clients_path, params: params, headers: auth_headers(user)

      expect(json).to have_key('client')
      expect(json['client']).to eq client_json(client)
    end

    it 'return errors' do
      post clients_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:params) { { id: client.id, client: { name: 'new name' } } }
    let(:client) { create :client, name: 'client' }
    let(:missing_name_params) { { client: { name: '' } } }

    it 'update client' do
      put client_path(client), params: params, headers: auth_headers(user)

      expect(client.reload.name).to eq 'new name'
    end

    it 'return updated Client' do
      put client_path(client), params: params, headers: auth_headers(user)

      expect(json).to have_key('client')
      expect(json['client']).to eq client_json(client.reload)
    end

    it 'return errors' do
      put client_path(client), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:params) { { id: client.id } }
    let(:client) { create :client, name: 'Client' }

    it 'return client' do
      get client_path(client), params: params, headers: auth_headers(user)

      expect(json).to have_key('client')
      expect(json['client']).to eq(client_json(client))
    end
  end
end
