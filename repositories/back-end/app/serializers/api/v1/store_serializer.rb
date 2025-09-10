module Api
  module V1
    class StoreSerializer < ActiveModel::Serializer
      attributes :id, :name, :created_at, :updated_at, :block_simultaneous_nfc, :checkout_type, :direct_checkout, :shop_url, :use_total_thc, :enable_automate_promotions, :enabled_continuous_cart

      has_one :logo, serializer: Api::V1::AssetSerializer
      belongs_to :client
      has_one :settings, serializer: Api::V1::StoreSettingSerializer
    end
  end
end
