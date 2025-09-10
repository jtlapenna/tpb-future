require 'rails_helper'

describe Article do
  let(:article) { build_stubbed :article }

  it 'is valid' do
    expect(article).to be_valid
  end

  it 'is not valid without title' do
    article.title = nil

    expect(article).not_to be_valid
    expect(article.errors[:title]).to eq ["can't be blank"]
  end

  it 'is not valid without text' do
    article.text = nil

    expect(article).not_to be_valid
    expect(article.errors[:text]).to eq ["can't be blank"]
  end

  it 'is not valid without tag & category' do
    article.tag = nil
    article.category = nil

    expect(article).not_to be_valid
    expect(article.errors[:tag]).to eq ["can't be blank"]
  end

  it 'is valid without tag but with category' do
    article.category = build :category
    article.tag = nil

    expect(article).to be_valid
  end

  it 'is valid without category but with tag' do
    article.category = nil
    article.tag = 'tag 1'

    expect(article).to be_valid
  end
end
