module Api
  module V1
    class AttributeValueSerializer < ActiveModel::Serializer
      attribute :name do
        object.attribute_def.name
      end
      attribute :value
    end
  end
end
