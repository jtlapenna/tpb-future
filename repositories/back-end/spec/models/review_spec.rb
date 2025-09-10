require 'rails_helper'

describe Review do
  let(:review) { build_stubbed :review }

  it 'is valid' do
    expect(review).to be_valid
  end

  it 'is not valid without reviewable' do
    review.reviewable = nil
    expect(review).not_to be_valid
    expect(review.errors[:reviewable]).to eq ['must exist']
  end

  it 'is not valid without text' do
    review.text = ''
    expect(review).not_to be_valid
    expect(review.errors[:text]).to eq ["can't be blank"]
  end
end
