module Api
  module V1
    class KioskAssetSerializer < ActiveModel::Serializer
      attributes :id, :text, :secondary_text, :text_position, :section_position,
                 :asset_position, :code, :created_at, :updated_at

      def text_position
        object.text_position&.label
      end

      def section_position
        object.section_position&.label
      end

      def asset_position
        object.asset_position&.label
      end

      has_many :asset_elements,
               key: 'pictures_in_pictures',
               serializer: Api::V1::AssetElementSerializer do
                 object.asset_elements.where(element_type: 'picture_in_picture')
               end

      has_many :asset_elements, key: 'dots', serializer: Api::V1::AssetElementSerializer do
        object.asset_elements.where(element_type: 'dot')
      end

      has_one :asset, serializer: Api::V1::AssetSerializer
    end
  end
end
