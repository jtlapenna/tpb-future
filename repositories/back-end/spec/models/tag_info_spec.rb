require 'rails_helper'

describe TagInfo do
  let(:tag_info) { build_stubbed :tag_info }

  it 'is valid' do
    expect(tag_info).to be_valid
  end

  it 'is not valid without tag' do
    tag_info.tag = nil
    expect(tag_info).not_to be_valid
    expect(tag_info.errors[:tag]).to eq ["can't be blank"]
  end

  it 'is not valid without description' do
    tag_info.description = nil
    expect(tag_info).not_to be_valid
    expect(tag_info.errors[:description]).to eq ["can't be blank"]
  end

  it 'tag is uique' do
    old_tag_info = create :tag_info, tag: 'a tag'

    tag_info.tag = 'a tag'
    expect(tag_info).not_to be_valid
    expect(tag_info.errors[:tag]).to eq ['Tag already exists.']
  end
end
