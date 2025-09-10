FactoryBot.define do
  factory :cart do
    is_active { false }
    phone_number { "MyString" }
    checkout_date { "2024-10-17 15:48:12" }
  end
end
