class AttributeValueSerializer < ActiveModel::Serializer
  attributes :id, :value

  belongs_to :attribute_def
end
