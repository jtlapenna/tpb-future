FactoryBot.define do
  factory :store_product_promotion do
    promotion { "MyText" }
    store_product { nil }
  end
end
