class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :tag_list

  belongs_to :category

  has_one :video

  has_many :attribute_values
  has_many :images
  has_many :reviews
end
