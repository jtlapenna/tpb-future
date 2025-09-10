require 'rails_helper'

RSpec.describe Api::V1::HealthController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to include('status', 'timestamp')
    end
  end

  describe 'GET #ping' do
    it 'returns http success' do
      get :ping
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq({ 'message' => 'pong' })
    end
  end
end 