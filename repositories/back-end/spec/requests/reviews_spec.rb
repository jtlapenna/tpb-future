require 'rails_helper'

describe 'Reviews API' do
  let(:user) { create :user }

  def review_json(review)
    review.as_json(only: %i[id user rate text reviewable_type reviewable_id])
  end

  context '#index' do
    let(:reviews) { Review.all.order(id: :desc) }
    let(:expected_reviews) { reviews.map { |r| review_json(r) } }

    before do
      create_list :review, 3
      get reviews_path, headers: auth_headers(user)
    end

    it 'respond with reviews' do
      expect(json).to have_key('reviews')
      expect(json['reviews'].count).to eq 3
      expect(json['reviews']).to eq expected_reviews
    end
  end

  context '#index#sort' do
    let(:reviews) { Review.all.order(user: :asc) }
    let(:expected_reviews) { reviews.map { |r| review_json(r) } }

    before do
      create :review, user: 'User 3'
      create :review, user: 'User 1'
      create :review, user: 'User 2'
      get reviews_path, params: { sort_by: 'user', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted reviews' do
      expect(json).to have_key('reviews')
      expect(json['reviews'].count).to eq 3
      expect(json['reviews']).to eq expected_reviews
    end
  end

  it_behaves_like 'paginated resource', Review

  context '#create' do
    let(:product) { create :product }
    let(:review) { Review.last }
    let(:params) { { review: { user: 'User 1', text: 'review text', reviewable_id: product.id, reviewable_type: 'Product' } } }
    let(:missing_text_params) { { review: { text: '', reviewable_id: product.id, reviewable_type: 'Product' } } }

    it 'create Review' do
      expect do
        post reviews_path, params: params, headers: auth_headers(user)
      end.to change {
        Review.count
      }.by 1
    end

    it 'created review values' do
      post reviews_path, params: params, headers: auth_headers(user)

      expect(review).to be
      expect(review.user).to eq 'User 1'
      expect(review.text).to eq 'review text'
    end

    it 'respond with review' do
      post reviews_path, params: params, headers: auth_headers(user)
      expect(json).to have_key('review')
      expect(json['review']).to eq review_json(review)
    end

    it 'return errors' do
      post reviews_path, params: missing_text_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('text')
      expect(json['errors']).to eq('text' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:params) { { id: review.id, review: { text: 'new text', user: 'new user' } } }
    let(:review) { create :review }
    let(:missing_name_params) { { review: { text: '' } } }

    it 'update review' do
      put review_path(review), params: params, headers: auth_headers(user)

      expect(review.reload.user).to eq 'new user'
      expect(review.reload.text).to eq 'new text'
    end

    it 'return updated review' do
      put review_path(review), params: params, headers: auth_headers(user)

      expect(json).to have_key('review')
      expect(json['review']).to eq review_json(review.reload)
    end

    it 'return errors' do
      put review_path(review), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('text')
      expect(json['errors']).to eq('text' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:params) { { id: review.id } }
    let(:review) { create :review }

    it 'return review' do
      get review_path(review), params: params, headers: auth_headers(user)

      expect(json).to have_key('review')
      expect(json['review']).to eq(review_json(review))
    end
  end
end
