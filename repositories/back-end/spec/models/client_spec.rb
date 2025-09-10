require 'rails_helper'

describe Client do
  let(:client) { build_stubbed :client }

  it 'is valid' do
    expect(client).to be_valid
  end

  it 'is active' do
    expect(client).to be_active
  end

  it 'is not valid without name' do
    client.name = nil
    expect(client).not_to be_valid
  end

  describe 'name' do
    let!(:client) { create :client }

    it 'should be unique' do
      another_client = build :client, name: client.name

      expect(another_client).not_to be_valid
      expect(another_client.errors[:name]).to eq ['has already been taken']
    end
  end
end
