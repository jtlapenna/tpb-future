require 'sidekiq/web'
require 'sidekiq/cron/web'
Rails.application.routes.draw do
  post 'user_token' => 'user_token#create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :clients, only: %i[index create update show]
  resources :products, only: %i[index create update show] do
    get :search, on: :collection
    get :tags, on: :member
  end
  resources :payment_gateway_providers
  resources :categories, only: %i[index create update show]
  resources :stores, only: %i[index create update show] do
    collection do
      post :get_inventory_data
    end
    get :tax_customer_types, on: :member
    post :generate_token, on: :member
    resources :store_syncs, only: %i[create show] do
      member do
        post :sync_item
        put :finish
      end
    end
    resources :store_prices
    resources :store_taxes
    resources :store_categories do
      collection do
        get :categories_by_brand
      end
      resources :store_category_taxes
    end
    resources :store_products, only: %i[index create update show destroy] do
      get :search, on: :collection
      resources :store_product_promotions
    end
    resources :store_articles, only: %i[index show update create destroy], path: 'articles' do
      get :default_products, on: :collection
    end
    resources :payment_gateways
    namespace :webhooks do
      resources :treez, only: [] do
        post :end_point, on: :collection
      end
      resources :shopify, only: [] do
        post :product_create, on: :collection
        post :product_update, on: :collection
        post :product_delete, on: :collection
        post :order_create, on: :collection
        post :order_update, on: :collection
      end
      resources :blaze, only: [] do
        post :end_point, on: :collection
      end
    end
  end
  resources :layout_positions, only: [:index]
  resources :brands, only: %i[index create update show]
  get 'download_csv' => 'brands#download_csv'
  resources :product_variants, only: %i[index create update show] do
    get :search, on: :collection
    get :tags, on: :member
  end
  resources :users, only: %i[index create update show] do
    get :current, on: :collection
  end
  resources :attribute_groups, only: %i[index create update show destroy]
  resources :attribute_defs, only: %i[index create update show destroy]
  resources :kiosks, only: %i[index create update show] do
    post :clone, on: :member
    resources :kiosk_layouts, only: %i[update show], as: 'layouts', path: 'layouts'
    resources :kiosk_products, only: %i[index show create new update destroy] do
      get :search, on: :collection
      get :compact, on: :collection
      get :new_categories, on: :collection
      resource :kiosk_product_layout, only: %i[show update], as: 'layout', path: 'layout'
    end
    resources :rfid_products, only: %i[index create new] do 
      get :change_history, on: :collection
    end
    resources :ad_configs, only: %i[index create show update destroy]
    resources :kiosk_brands, only: %i[index], as: 'brands', path: 'brands'
  end
  resources :tags, only: [:index]
  resources :assets, only: [:destroy] do
    get :upload_request, on: :collection
  end
  resources :tag_infos, only: %i[index create update show destroy]
  resources :reviews, only: %i[index create update show destroy]
  resources :articles, only: %i[index create update show destroy]
  resources :product_layouts, only: %i[index create update show]
  resources :customers, only: %i[] do
    post :search, on: :collection
  end
  namespace :api do
    namespace :v1 do
      # Health check endpoints
      get 'health', to: 'health#index'
      get 'ping', to: 'health#ping'
      
      # API resources
      resources :users, only: [:index, :show]
      match 'stats' => 'application#stats', via: :get
      resources :customer_order, only: %i[index create update], path: ':catalog_id/customer_order'
      resources :products, only: %i[index show], path: ':catalog_id/products' do
        get :tags, on: :member
        get :reviews, on: :member
        get :similars, on: :member
        get :minimal, on: :collection
        get :maximal, on: :collection
        get :check_products_availability, on: :collection
        post :check_products_expired_status, on: :collection
        post :share, on: :member
      end
      resources :ad_banner_locations, path: 'widget-locations'
      resources :categories, only: [:index], path: ':catalog_id/categories'
      resources :brands,     only: [:index], path: ':catalog_id/brands'
      resource :stores do
        match 'show' => 'stores#show', via: :get, as: 'show'
        resources :ad_banners, path: ':store_id/widgets'
      end
      resource :catalogs, path: ':catalog_id', only: [] do
        get :settings, on: :member
        match 'tags' => 'catalogs#tags', via: :get
        get :widgets, on: :member
        get :rfids, on: :member
        resources :articles, only: [:index], controller: :catalog_articles
        resources :customers, only: %i[index create]
        resources :orders, only: %i[create update] do
          collection do
            put :status
            post :preview_order
            get :discount
          end
        end
        resources :carts, only: %i[index] do
          post :validate, on: :collection
          post :add_items, on: :collection
          post :update_item, on: :collection
          post :create_or_merge, on: :collection
          get :exists, on: :collection
        end
      end
    end
  end
  mount Sidekiq::Web => '/sidekiq'
end