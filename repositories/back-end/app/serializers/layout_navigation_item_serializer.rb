class LayoutNavigationItemSerializer < ActiveModel::Serializer
  attributes :id, :label, :link, :title, :description, :order

  has_one :asset
end
