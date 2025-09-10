require 'rails_helper'

describe User do
  let(:user) { build_stubbed :user }

  it 'is valid' do
    expect(user).to be_valid
  end

  it 'is active' do
    expect(user).to be_active
  end

  it 'is valid without name' do
    user.name = nil
    expect(user).to be_valid
  end

  it 'is not valid without an email' do
    user.email = nil
    expect(user).not_to be_valid
  end

  it 'with client isnt admin' do
    user.client = create :client
    expect(user).not_to be_admin
  end

  context 'email' do
    let!(:user) { create :user, email: 'email@email.com' }

    it 'should be unique' do
      another_user = build :user, email: 'email@email.com'

      expect(another_user).not_to be_valid
      expect(another_user.errors[:email]).to eq ['has already been taken']
    end
  end

  context '#from_token_payload' do
    let(:user) { create :user }

    it 'return user when active' do
      u = User.from_token_payload('sub' => user.id, 'aud' => ['backend'])
      expect(u).to be
      expect(u).to eq user
    end

    it 'raise when inactive' do
      user.update!(active: false)

      expect do
        User.from_token_payload('sub' => user.id, 'aud' => ['backend'])
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context '#to_token_payload' do
    let(:user) { create :user }

    it 'token payload' do
      user.touch
      expect(user.to_token_payload).to eq(sub: user.id, aud: [:backend])
    end
  end
end
