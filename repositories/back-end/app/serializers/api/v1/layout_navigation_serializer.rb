module Api
  module V1
    class LayoutNavigationSerializer < ActiveModel::Serializer
      attributes :id

      has_many :items, serializer: Api::V1::LayoutNavigationItemSerializer do
        object.items.order(:order)
      end
    end
  end
end
