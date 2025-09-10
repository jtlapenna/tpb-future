require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Health' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/api/v1/health' do
    example 'Get application health status' do
      do_request
      expect(status).to eq(200)
      expect(JSON.parse(response_body)).to include('status', 'timestamp')
    end
  end

  get '/api/v1/ping' do
    example 'Simple ping endpoint' do
      do_request
      expect(status).to eq(200)
      expect(JSON.parse(response_body)).to eq({ 'message' => 'pong' })
    end
  end
end 