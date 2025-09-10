require 'rails_helper'

describe 'API V1 Store articles' do
  include Api::V1::SerializationHelper::Products

  let(:kiosk) { create :kiosk, store: store }
  let(:store) { create :store, categories_count: 0 }

  def article_json(article)
    a_json = article.as_json(
      only: %i[id store_id article_id],
      methods: %i[tag text title icon excerpt category],
      include: { category: { only: %i[id name] } }
    ).merge(
      'created_at' => article.created_at.iso8601(3),
      'updated_at' => article.updated_at.iso8601(3)
    )
    a_json['products'] = []
    if article.category
      a_json['category'].merge!(
        'created_at' => article.category.created_at.iso8601(3),
        'updated_at' => article.category.updated_at.iso8601(3)
      )
    end
    a_json
  end

  describe '#index' do
    let(:store) { create :store }
    let(:kiosk) { create :kiosk, store: store }
    let!(:store_articles) { create_list :store_article, 3, store: store }
    let(:expected_articles) { store.store_articles.order(id: :desc).map { |art| article_json(art) } }

    before do
      create :store_article
      get api_v1_catalogs_articles_path(kiosk), headers: auth_headers(store)
    end

    it 'respond with articles' do
      expect(json).to have_key('articles')
      expect(json['articles'].count).to eq 3
      expect(json['articles']).to eq expected_articles
    end

    context 'return article products' do
      let(:store) { create :store, categories_count: 1 }
      let(:kiosk) { create :kiosk, store: store }
      let(:category) { store.store_categories.first }
      let(:variant) { create :product_variant }
      let(:expected_product) { product_json(store.store_products.tagged_with('tag 1').order(id: :asc).first) }
      let(:store_article) { store_articles.last }

      before do
        create_list :store_product, 12, store_category: category, product_variant: variant, tag_list: ['tag 1']
        store_article.article.update_column(:tag, 'tag 1')
      end

      context 'when article has no kiosk products' do
        it 'respond with article first 10 products' do
          get api_v1_catalogs_articles_path(kiosk), headers: auth_headers(store)

          expect(json).to have_key('articles')
          expect(json['articles'].count).to eq 3
          expect(json['articles'][0]).to have_key 'products'
          expect(json['articles'][0]['products'].count).to eq 10
          expect(json['articles'][0]['products'][0]).to eq expected_product
        end

        it 'respond article first 10 product ids when minimal payload is requested' do
          expected_product = store.store_products.tagged_with('tag 1').order(id: :asc).first(10).pluck(:id)

          get api_v1_catalogs_articles_path(kiosk, minimal: true), headers: auth_headers(store)

          expect(json).to have_key('articles')
          expect(json['articles'].count).to eq 3
          expect(json['articles'][0]).to have_key 'products'
          expect(json['articles'][0]['products'].count).to eq 10
          expect(json['articles'][0]['products']).to eq expected_product
        end
      end

      context 'when article has some' do
        it 'respond with all kiosk products' do
          products = create_list :store_product, 11, store_category: category, product_variant: variant
          expected_products = products.map { |p| product_json(p) }

          store_article.store_products << products

          get api_v1_catalogs_articles_path(kiosk), headers: auth_headers(store)

          expect(json).to have_key('articles')
          expect(json['articles'].count).to eq 3
          expect(json['articles'][0]).to have_key 'products'
          expect(json['articles'][0]['products'].count).to eq 11
          expect(json['articles'][0]['products']).to eq expected_products
        end

        it 'respond with all kiosk product ids when minimal payload is requested' do
          products = create_list :store_product, 11, store_category: category, product_variant: variant
          expected_products = products.map(&:id)

          store_article.store_products << products

          get api_v1_catalogs_articles_path(kiosk, minimal: true), headers: auth_headers(store)

          expect(json).to have_key('articles')
          expect(json['articles'].count).to eq 3
          expect(json['articles'][0]).to have_key 'products'
          expect(json['articles'][0]['products'].count).to eq 11
          expect(json['articles'][0]['products']).to eq expected_products
        end
      end
    end
  end

  it_behaves_like 'paginated resource', StoreArticle do
    let(:url_params) { { kiosk_id: kiosk.id } }
    let(:resource_name) { 'article' }
    let(:skip_creation) { true }
    let(:headers) { auth_headers(store) }
    let(:path) { api_v1_catalogs_articles_path(kiosk) }

    before do
      StoreArticle.destroy_all
      create_list :store_article, 15, store: store
    end
  end
end
