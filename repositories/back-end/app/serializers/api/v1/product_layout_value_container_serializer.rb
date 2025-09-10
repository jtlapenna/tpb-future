module Api
  module V1
    class ProductLayoutValueContainerSerializer < ActiveModel::Serializer
      has_many :media, serializer: Api::V1::ProductLayoutValueSerializer

      has_many :dots, serializer: Api::V1::ProductLayoutValueSerializer

      has_many :texts, serializer: Api::V1::ProductLayoutValueSerializer

      def media
        values.select(&:element_medium?)
      end

      def dots
        values.select(&:element_dot?)
      end

      def texts
        values.select(&:element_text?)
      end

      private

      def values
        instance_options[:values] || []
      end
    end
  end
end
