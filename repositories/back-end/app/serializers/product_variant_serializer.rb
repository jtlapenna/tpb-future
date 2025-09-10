class ProductVariantSerializer < ActiveModel::Serializer
  attributes :id, :name, :sku, :description, :tag_list, :override_tags

  belongs_to :brand
  belongs_to :category
  belongs_to :product, serializer: ProductMinimalSerializer

  has_many :attribute_values
  has_many :images
  has_many :reviews

  has_one :video

  attribute :is_wildcard do
    object.id == ENV['WILDCARD_VARIANT_ID'].to_i
  end
end
