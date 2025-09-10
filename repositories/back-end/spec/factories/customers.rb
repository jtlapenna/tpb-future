FactoryBot.define do
  factory :customer do
    customer_id { Faker::Number.rand(10_000_000..10_009_998) }
  end
end
