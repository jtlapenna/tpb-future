class ProductLayoutSerializer < ActiveModel::Serializer
  attributes :id, :name, :stylesheet

  has_many :elements

  has_many :tabs
end
