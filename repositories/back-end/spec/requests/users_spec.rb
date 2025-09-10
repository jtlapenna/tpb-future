require 'rails_helper'

describe 'Users API' do
  let(:admin_user) { create :user }

  def user_json(user)
    includes = {
      client: { only: %i[id name] }
    }
    u_json = user.as_json(only: %i[id name email], include: includes)

    u_json['client'] = nil unless u_json['client']
    u_json
  end

  context '#current' do
    it 'return current user' do
      get current_users_path, headers: auth_headers(admin_user)

      expect(json).to have_key('user')
      expect(json['user']).to eq(user_json(admin_user))
    end
  end

  context '#index' do
    let(:users) { User.all.order(id: :desc) }
    let(:expected_users) { users.map { |c| user_json(c) } }

    before do
      create_list :user, 3
      get users_path, headers: auth_headers(admin_user)
    end

    it 'respond with users' do
      expect(json).to have_key('users')
      expect(json['users'].count).to eq 4 # we create 3 and admin is another user
      expect(json['users']).to eq expected_users
    end
  end

  context '#index#sort' do
    let(:users) { User.all.order(name: :asc) }
    let(:expected_users) { users.map { |c| user_json(c) } }

    before do
      create :user, name: 'User 3'
      create :user, name: 'User 1'
      create :user, name: 'User 2'
      get users_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(admin_user)
    end

    it 'respond with sorted users' do
      expect(json).to have_key('users')
      expect(json['users'].count).to eq 4 # we create 3 and admin is another user
      expect(json['users']).to eq expected_users
    end
  end

  context 'admin_user as admin' do
    let(:user) { admin_user }

    it_behaves_like 'paginated resource', User do
      let(:skip_creation) { true }

      before do
        create_list :user, 14
      end
    end
  end

  context '#create' do
    let(:user) { User.last }
    let(:params) { { user: { email: 'User 1', password: 'the_password', password_confirmation: 'the_password' } } }
    let(:missing_name_params) { { user: { active: false } } }

    it 'create User' do
      admin_user
      expect do
        post users_path, params: params, headers: auth_headers(admin_user)
      end.to change {
        User.count
      }.by 1
    end

    it 'respond with User' do
      post users_path, params: params, headers: auth_headers(admin_user)

      expect(json).to have_key('user')
      expect(json['user']).to eq user_json(user)
    end

    it 'return errors' do
      post users_path, params: missing_name_params, headers: auth_headers(admin_user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('email')
      expect(json['errors']).to have_key('password')
      expect(json['errors']).to eq('password' => ["can't be blank"], 'email' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:params) { { id: user.id, user: { email: 'new@email.com' } } }
    let(:user) { create :user, email: 'user@email.com' }
    let(:missing_name_params) { { user: { email: '' } } }

    it 'update user' do
      put user_path(user), params: params, headers: auth_headers(admin_user)

      expect(user.reload.email).to eq 'new@email.com'
    end

    it 'return updated User' do
      put user_path(user), params: params, headers: auth_headers(admin_user)

      expect(json).to have_key('user')
      expect(json['user']).to eq user_json(user.reload)
    end

    it 'return errors' do
      put user_path(user), params: missing_name_params, headers: auth_headers(admin_user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('email')
      expect(json['errors']).to eq('email' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:params) { { id: user.id } }
    let(:user) { create :user, email: 'user@email.com' }

    it 'return user' do
      get user_path(user), params: params, headers: auth_headers(admin_user)

      expect(json).to have_key('user')
      expect(json['user']).to eq(user_json(user))
    end
  end
end
