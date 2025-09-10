class AttributeGroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :group_type, :order

  has_many :attribute_defs
end
