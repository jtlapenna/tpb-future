require 'acceptance_helper'

resource 'Products', type: :request do
  let(:kiosk) { create :kiosk }
  let(:api_key) { auth_token(store) }
  let(:store) { kiosk.store }

  explanation 'Products resources'

  authentication :apiKey, :api_key, description: 'Private key for API access', name: 'Authorization'
  header 'Content-Type', 'application/json'

  get '/api/v1/:catalog_id/products' do
    let(:catalog_id) { kiosk.id }

    sortable_api_parameters
    pageable_api_parameters
    parameter :category_id, type: :integer, with_example: true
    parameter :brand_id, type: :integer, with_example: true
    parameter :tagged_with, type: :string
    parameter :with_rfid, type: :boolean

    before do
      create_list :kiosk_product, 3, kiosk: kiosk
    end

    context '200' do
      example_request 'get products' do
        expect(status).to eq 200

        expect(json).to have_key 'products'
        expect(json['products'].count).to eq 3
      end
    end
  end

  get '/api/v1/:catalog_id/products/minimal' do
    let(:catalog_id) { kiosk.id }

    before do
      create :store_product, store: store

      create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
      create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
      create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
    end

    context '200' do
      example_request 'get products' do
        expect(status).to eq 200

        expect(json).to have_key 'products'
        expect(json['products'].count).to eq 3
      end
    end
  end

  get '/api/v1/:catalog_id/products/:product_id' do
    let(:catalog_id) { kiosk.id }
    let(:store_product) { create(:store_product, store: store) }
    let(:product_id) { store_product.id }

    context '200' do
      before do
        create :kiosk_product, kiosk: kiosk, store_product: store_product
      end

      example_request 'get product details' do
        expect(status).to eq 200
      end
    end
  end

  get '/api/v1/:catalog_id/products/:product_id/tags' do
    let(:catalog_id) { kiosk.id }
    let(:store_product) { create(:store_product, store: store, tag_list: 'tag 1, tag 2') }
    let(:product_id) { store_product.id }

    before do
      create :kiosk_product, kiosk: kiosk, store_product: store_product
      create :tag_info, tag: 'tag 1'
      create :tag_info, tag: 'tag 2'
    end

    context '200' do
      example_request 'get product tags' do
        expect(status).to eq 200

        expect(json).to have_key 'tags'
        expect(json['tags'].count).to eq 2
      end
    end
  end

  get '/api/v1/:catalog_id/products/:product_id/reviews' do
    let(:catalog_id) { kiosk.id }
    let(:store_product) { create(:store_product, store: store, product_variant: product_variant) }
    let(:product_id) { store_product.id }
    let(:product_variant) { create :product_variant }

    before do
      create :kiosk_product, kiosk: kiosk, store_product: store_product
      create :review, reviewable: product_variant
      create :review, reviewable: product_variant
    end

    context '200' do
      example_request 'get product reviews' do
        expect(status).to eq 200

        expect(json).to have_key 'reviews'
        expect(json['reviews'].count).to eq 2
      end
    end
  end

  get '/api/v1/:catalog_id/products/:product_id/similars' do
    let(:catalog_id) { kiosk.id }
    let(:store_product) { create(:store_product, store: store, tag_list: 'tag 1, tag 2') }
    let(:product_id) { store_product.id }

    before do
      create :kiosk_product, kiosk: kiosk, store_product: store_product
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, store: store, tag_list: 'tag 1')
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, store: store, tag_list: 'tag 2')
    end

    context '200' do
      example_request 'get similars products' do
        expect(status).to eq 200

        expect(json).to have_key 'products'
        expect(json['products'].count).to eq 2
      end
    end
  end
end
