class AttributeDefSerializer < ActiveModel::Serializer
  attributes :id, :name, :restricted, :values

  belongs_to :attribute_group, fields: %i[id name]
end
