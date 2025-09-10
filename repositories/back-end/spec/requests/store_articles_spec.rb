require 'rails_helper'

describe 'Store articles API' do
  let(:user) { create :user }
  let(:store) { create :store }

  def article_json(article, full_includes: false, products: false)
    a_json = article.as_json(
      only: %i[id article_id store_id],
      methods: %i[text tag title icon excerpt category],
      include: { category: { only: %i[id name] } }
    )

    if article.category
      a_json['category'].merge!(
        'created_at' => article.category.created_at.iso8601(3),
        'updated_at' => article.category.updated_at.iso8601(3)
      )
    end

    if products || full_includes
      a_json['store_products'] = article.store_products.map { |prod| store_product_json(prod, full_includes: full_includes) }
    end

    a_json
  end

  def store_product_json(object, detail: false, full_includes: false)
    o_json = object.as_json(
      only: %i[id sku name description share_email_template share_sms_template stock override_tags featured status weight],
      methods: [:tag_list],
      include: { video: { only: %i[id url] } }
    )

    if full_includes || detail
      o_json['store_category'] = store_category_json(object.store_category)
      o_json['product_variant'] = variant_json(object.product_variant)
      if full_includes
        o_json['thumb_image'] = object.thumb_image
        o_json['images'] = object.images
      end
    end

    o_json
  end

  def store_category_json(object)
    object.as_json(only: %i[id name order store_id])
  end

  def variant_json(object)
    object.as_json(
      only: %i[id name sku description override_tags],
      methods: [:tag_list],
      include: { video: { only: %i[id url] } }
    ).merge(
      'product' => product_json(object.product),
      'is_wildcard' => object.id == ENV['WILDCARD_VARIANT_ID'].to_i
    )
  end

  def product_json(object)
    object.as_json(only: %i[id name])
  end

  context '#index' do
    let(:store) { create :store }
    let(:articles) { store.store_articles.all.order(id: :desc) }
    let(:expected_articles) { articles.map { |a| article_json(a) } }

    before do
      create_list :store_article, 3, store: store, store_products: [create(:store_product)]
      get store_store_articles_path(store), headers: auth_headers(user)
    end

    it 'respond with store articles' do
      expect(json).to have_key('articles')
      expect(json['articles'].count).to eq 3
      expect(json['articles']).to eq expected_articles
    end

    context 'when there is not results' do
      before do
        StoreArticle.destroy_all
        get store_store_articles_path(store), headers: auth_headers(user)
      end

      it 'respond with articles key' do
        expect(json).to have_key('articles')
        expect(json['articles'].count).to eq 0
      end
    end
  end

  context '#index#sort' do
    let(:store) { create :store, categories_count: 0 }
    let(:articles) { store.store_articles.all.order(id: :asc) }
    let(:expected_articles) { articles.map { |a| article_json(a) } }

    before do
      create_list :store_article, 3, store: store

      get store_store_articles_path(store), params: { sort_by: 'id', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted products' do
      expect(json).to have_key('articles')
      expect(json['articles'].count).to eq 3
      expect(json['articles']).to eq expected_articles
    end
  end

  it_behaves_like 'paginated resource', StoreArticle do
    let(:store) { create :store, categories_count: 0 }
    let(:url_params) { { store_id: store.id } }
    let(:resource_name) { 'article' }
    let(:skip_creation) { true }

    before do
      StoreArticle.destroy_all
      create_list :store_article, 15, store: store
    end
  end

  context '#create' do
    let(:store) { create :store, categories_count: 0 }
    let(:main_article) { create :article }
    let(:article) { StoreArticle.last }
    let(:params) { { store_id: store.id, article: { article_id: main_article.id } } }
    let(:missing_article_params) { { store_id: store.id, article: { article_id: 0 } } }

    it 'create article' do
      expect do
        post store_store_articles_path(store), params: params, headers: auth_headers(user)
      end.to change {
        store.store_articles.count
      }.by 1
    end

    it 'respond with product' do
      post store_store_articles_path(store), params: params, headers: auth_headers(user)

      expect(json).to have_key('article')
      expect(json['article']).to eq article_json(article, products: true)
    end

    it 'return errors' do
      post store_store_articles_path(store), params: missing_article_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('article')
      expect(json['errors']).to eq('article' => ['must exist'])
    end
  end

  context '#update' do
    let(:store) { create :store, categories_count: 0 }
    let(:main_article) { create :article }
    let(:params) { { id: article.id, store_id: store.id, article: { article_id: main_article.id, store_product_ids: [product.id] } } }
    let(:article) { create :store_article, store: store }
    let(:missing_name_params) { { store_id: store.id, article: { article_id: 0 } } }
    let(:category) { create :store_category, store: store }
    let(:product) { create :store_product, store_category: category }

    it 'return updated article' do
      put store_store_article_path(store, article), params: params, headers: auth_headers(user)

      expect(json).to have_key('article')
      expect(json['article']).to eq article_json(article.reload, products: true)
    end

    it 'update article store products' do
      expect do
        put store_store_article_path(store, article), params: params, headers: auth_headers(user)
      end.to change { article.store_products.count }.by 1

      expect(article.store_products).to eq [product]
    end

    it 'return errors' do
      put store_store_article_path(store, article), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('article')
      expect(json['errors']).to eq('article' => ['must exist'])
    end
  end

  context '#show' do
    let(:store) { create :store, categories_count: 0 }
    let(:params) { { id: article.id, store_id: store.id } }
    let(:article) { create :store_article, store: store, store_products: [create(:store_product)] }

    it 'return article' do
      get store_store_article_path(store, article), params: params, headers: auth_headers(user)

      expect(json).to have_key('article')
      # expect(json['article']).to eq(article_json(article, full_includes: true))
      expect(json['article']['store_products']).to eq(article_json(article, full_includes: true)['store_products'])
    end
  end

  context '#destroy' do
    let(:store) { article.store }
    let(:article) { create :store_article }
    let(:params) { { store_id: store.id, id: article.id } }

    it 'respond ok' do
      expect do
        delete store_store_article_path(store, article), params: params, headers: auth_headers(user)
      end.to change {
        store.store_articles.count
      }.by -1
    end
  end

  context '#default_products' do
    let(:store) { create :store, categories_count: 0 }
    let(:category) { create :category }
    let(:store_category) { create :store_category, store: store }
    let(:params) { { article_id: article.article_id, store_id: store.id } }

    context '#with-tag' do
      let(:article) { create :store_article, store: store, store_products: [create(:store_product)] }
      let(:variant) { create :product_variant }
      let!(:products) do
        [
          create(:store_product, store_category: store_category, product_variant: create(:product_variant, product: create(:product, tag_list: article.tag))),
          create(:store_product, store_category: store_category, product_variant: create(:product_variant, tag_list: article.tag))
        ] + create_list(:store_product, 9, store_category: store_category, product_variant: variant, tag_list: article.tag)
      end
      let(:expected_products) { products.first(10).map { |p| store_product_json(p, detail: true) } }

      before { create :store_product, product_variant: variant, tag_list: article.tag }

      it "return first 10 store products article's tag with" do
        get default_products_store_store_articles_path(store), params: params, headers: auth_headers(user)

        expect(json).to have_key('store_products')
        expect(json['store_products']).to match_array expected_products
      end
    end

    context '#with-category' do
      let(:variant) { create(:product_variant, product: create(:product, category: category)) }
      let(:article) { create :store_article, store: store, store_products: [create(:store_product)], article: create(:article, category: category) }
      let!(:products) do
        [
          create(:store_product, store_category: create(:store_category, store: store), product_variant: variant),
          create(:store_product, store_category: create(:store_category, store: store), product_variant: create(:product_variant, product: create(:product, category: category)))
        ] + create_list(:store_product, 10, store_category: store_category, product_variant: variant)
      end

      let(:expected_products) { products.first(10).map { |p| store_product_json(p, detail: true) } }

      before { create(:store_product, store_category: store_category) }

      it "return first 10 store products article's category with" do
        get default_products_store_store_articles_path(store), params: params, headers: auth_headers(user)

        expect(json).to have_key('store_products')
        expect(json['store_products']).to match_array expected_products
      end
    end

    context '#with-tag & category' do
      let(:article) { create :store_article, store: store, store_products: [create(:store_product)], article: create(:article, category: category) }
      let(:variant) { create(:product_variant, product: create(:product, category: category)) }
      let!(:products) do
        create_list(:store_product, 5, store_category: store_category, product_variant: variant) +
          [
            create(:store_product, store_category: store_category, product_variant: create(:product_variant, product: create(:product, tag_list: article.tag))),
            create(:store_product, store_category: store_category, product_variant: create(:product_variant, tag_list: article.tag))
          ] + create_list(:store_product, 4, store_category: store_category, product_variant: variant, tag_list: article.tag)
      end
      let(:expected_products) { products.first(10).map { |p| store_product_json(p, detail: true) } }

      before { create :store_product, product_variant: variant, tag_list: article.tag }

      it "return first 10 store products article's tag with" do
        get default_products_store_store_articles_path(store), params: params, headers: auth_headers(user)

        expect(json).to have_key('store_products')
        expect(json['store_products']).to match_array expected_products
      end
    end
  end
end
