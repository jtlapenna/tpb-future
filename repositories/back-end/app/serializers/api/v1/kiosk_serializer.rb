module Api
  module V1
    class KioskSerializer < ActiveModel::Serializer
      has_many :ad_configs, serializer: AdConfigSerializer

      attribute :notifications_send_to_customer, key: :notify_to_customer do
        object.store.notifications_send_to_customer
      end

      attribute :notifications_enabled, key: :notify_by_email do
        object.store.notifications_enabled
      end

      attribute :api_type do
        object.store.api_type
      end

      attributes :sensor_method, :sensor_threshold, :location, :tag_list

      has_one :layout, serializer: Api::V1::KioskLayoutSerializer
    end
  end
end
