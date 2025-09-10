FactoryBot.define do
  factory :client do
    name { Faker::Company.unique.name }
    active { true }
  end

  factory :store do
    transient do
      categories_count { 3 }
    end

    name { Faker::Company.unique.name }
    active { true }
    client
    regenerate_jti { true }

    factory :treez_store do
      api_type        { 'treez' }
      api_key         { 'xxxxx' }
      api_client_id   { 'yyy' }
      dispensary_name { 'xxx' }
      sync_frequency  { '1' }
      api_version     { 'v1.0' }
    end

    factory :headset_store do
      api_type        { 'headset' }
      api_key         { 'xxxxx' }
      sync_frequency  { '1' }
      api_store_id    { 'xxx' }
    end

    factory :flowhub_store do
      api_type            { 'flowhub' }
      api_key             { 'xxxxx' }
      location_id         { 'xxx' }
      api_client_id       { 'yyy' }
      sync_frequency      { '1' }
      auth0_client_id     { 'auth0_xxx' }
      auth0_client_secret { 'auth0_yyy' }
    end

    factory :leaflogix_store do
      api_type        { 'leaflogix' }
      api_key         { 'xxxxx' }
      sync_frequency  { '1' }
    end

    after(:create) do |store, evaluator|
      if evaluator.categories_count > 0
        create_list(:store_category, evaluator.categories_count, store: store)
      end
    end
  end

  factory :kiosk_asset do
    association :kiosk_layout
  end

  factory :welcome_asset do
    association :kiosk_layout
  end

  factory :kiosk_layout do
    association :kiosk
  end

  factory :asset_element do
    association :kiosk_asset
  end

  factory :store_setting do
    association :store
  end

  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    category
  end

  factory :category do
    name { Faker::Commerce.unique.department }
  end

  factory :product_variant do
    product
    brand
    sku { Faker::Code.unique.ean }
    name { "#{product.name} variant" }
    description { "#{product.name} variant description" }
  end

  factory :kiosk do
    name { Faker::Lorem.unique.words(number: 2).join(' ') }
    store
    active { true }
  end

  factory :store_category do
    name { Faker::Commerce.department }
    store
  end

  factory :store_product do
    transient do
      prices { [] }
    end

    store_category
    product_variant
    sku { Faker::Code.unique.ean }
    name { Faker::Commerce.product_name }
    weight { Faker::Number.between(from: 1, to: 100) }
    description { Faker::Lorem.paragraph }
    status { :published }

    after(:build) do |store_product, evaluator|
      evaluator.prices.each do |name, value|
        store_product.product_values.build name: name, value: value
      end
    end
  end

  factory :brand do
    name { Faker::Company.unique.name }
    description { Faker::Lorem.paragraph }
  end

  factory :user do
    email { Faker::Internet.unique.email }
    name { Faker::Name.name }
    password { '12345678' }
    password_confirmation { '12345678' }
  end

  factory :user_client, parent: :user do
    association :client, strategy: :create
  end

  factory :attribute_group do
    name { Faker::Lorem.unique.word }
  end

  factory :attribute_def do
    name { Faker::Lorem.word }
    attribute_group
  end

  factory :attribute_value do
    value { Faker::Lorem.word }
    attribute_def
    association :target, factory: :product
  end

  factory :product_value do
    value { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    name  { 'REC g' }
    association :valuable, factory: :store_product
  end

  factory :image do
    url { Faker::Internet.url }
    association :imageable, factory: :product
  end

  factory :asset do
    url { Faker::Internet.url }
    association :source, factory: :kiosk_asset
  end

  factory :store_sync do
    store
  end

  factory :store_sync_item do
    store_sync
    sku { Faker::Code.unique.ean }
    stock { Faker::Number.number(digits: 2) }
    category { Faker::Lorem.word }
    active { true }
  end

  factory :store_price do
    name { Faker::Lorem.unique.word }
    store
  end

  factory :tag_info do
    tag { Faker::Lorem.unique.word }
    description { Faker::Lorem.paragraph }
  end

  factory :review do
    user { Faker::Name.name }
    rate { Faker::Number.number(digits: 1) }
    text { Faker::Lorem.paragraph }
    association :reviewable, factory: :product
  end

  factory :layout_position do
    label { %w[top right left bottom fullscreen][rand(4)] }
  end

  factory :rfid_product do
    rfid { Faker::Code.unique.asin }
    association :rfid_entity, factory: :kiosk_product
  end

  factory :article do
    title { Faker::Lorem.question }
    text  { Faker::Lorem.paragraph }
    tag   { Faker::Lorem.word }
    icon  { Faker::Lorem.word }
    excerpt { Faker::Lorem.paragraph }
    category
  end

  factory :store_article do
    article
    store
  end

  factory :layout_navigation do
    association :kiosk_layout
  end

  factory :layout_navigation_item do
    label { Faker::Company.unique.name }
    title { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    association :layout_navigation
    order { Faker::Number.between(from: -10, to: 100) }
  end

  factory :customer_order do
    customer_id { rand(10_000_000..10_009_998) }
    order_id { rand(10_000_000..10_009_998) }
    association :store, strategy: :build
  end

  factory :kiosk_product do
    store_product
    kiosk

    after(:build) do |kiosk_product, _evaluator|
      kiosk_product.store_product.store = kiosk_product.kiosk.store
    end
  end

  factory :product_layout do
    name { Faker::Lorem.unique.word }
  end

  factory :product_layout_tab do
    name { Faker::Lorem.word }
    order { Faker::Number.number(digits: 2) }
    product_layout
  end

  factory :product_layout_element do
    association :source, factory: :product_layout_tab
    element_type { ProductLayoutElement.element_types.keys.sample }

    coord_x { Faker::Number.number(digits: 2) }
    coord_y { Faker::Number.number(digits: 2) }

    trait :for_layout do
      association :source, factory: :product_layout
    end

    factory :product_layout_medium do
      element_type { :medium }
    end

    factory :product_layout_dot do
      element_type { :dot }
    end

    factory :product_layout_text do
      element_type { :text }
    end
  end

  factory :product_layout_value do
    product_layout_element
    kiosk_product

    factory :product_layout_medium_value do
      association :product_layout_element, factory: :product_layout_medium

      trait :for_layout do
        association :product_layout_element, :for_layout, factory: :product_layout_medium
      end

      after(:build) do |element|
        element.asset ||= build(:asset, source: element)
      end
    end

    factory :product_layout_dot_value do
      association :product_layout_element, factory: :product_layout_dot
      link { Faker::Internet.url }
    end

    factory :product_layout_text_value do
      association :product_layout_element, factory: :product_layout_text
      content { Faker::Lorem.words(number: 2).join(' ') }
    end
  end

  factory :purchase_limit do
    limit { Faker::Number.between(from: 1, to: 100) }
    store_setting
    store_categories { build_list :store_category, 1, store: store_setting.store }
  end
end
