FactoryBot.define do
  factory :payment_gateway do
    store { nil }
    payment_gateway_provider { nil }
    api_settings { "" }
  end
end
