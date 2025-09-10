class BrandSerializer < ActiveModel::Serializer
  attributes :id, :name, :description

  has_one :logo
end
