require 'rails_helper'

describe 'UserToken API' do
  let(:user) { create :user }

  def user_json(user)
    includes = {
      client: { only: %i[id name] }
    }

    u_json = user.as_json(only: %i[id name email], include: includes)

    u_json['client'] = nil unless u_json['client']
    u_json
  end

  context '#create' do
    it 'respond with token' do
      post user_token_path, params: { auth: { email: user.email, password: '12345678' } }

      expect(json).to have_key 'jwt'

      token = json['jwt']
      expect(token.size).to be > 20
      expect(token.split('.').count).to eq 3
    end

    it 'respond with user' do
      post user_token_path, params: { auth: { email: user.email, password: '12345678' } }

      expect(json).to have_key 'user'
      expect(json['user']).to eq user_json(user)
    end
  end
end
