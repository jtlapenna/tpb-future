class ProductLayoutTabSerializer < ActiveModel::Serializer
  attributes :id, :name, :order

  has_many :elements
end
