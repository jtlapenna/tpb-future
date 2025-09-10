module Api
  module V1
    class ProductLayoutValueSerializer < ActiveModel::Serializer
      delegate :element_text?, :element_medium?, :element_dot?, to: :object

      attributes :coord_x, :coord_y

      attribute :width, unless: :element_dot?

      attribute :link, unless: :element_text?

      attribute :content, if: :element_text?

      attribute :asset, if: :element_medium? do
        Api::V1::AssetSerializer.new(object.asset) if object.asset
      end
    end
  end
end
