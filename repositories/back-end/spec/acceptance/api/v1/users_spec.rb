require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Users' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/api/v1/users' do
    example 'List all users' do
      create_list(:user, 3)
      do_request
      expect(status).to eq(200)
      expect(JSON.parse(response_body).length).to eq(3)
    end
  end

  get '/api/v1/users/:id' do
    parameter :id, 'User ID', required: true

    let(:user) { create(:user) }
    let(:id) { user.id }

    example 'Get a specific user' do
      do_request
      expect(status).to eq(200)
      expect(JSON.parse(response_body)['id']).to eq(user.id)
    end

    example 'Get a non-existent user', document: false do
      let(:id) { 'invalid' }
      do_request
      expect(status).to eq(404)
      expect(JSON.parse(response_body)['error']).to eq('User not found')
    end
  end
end 