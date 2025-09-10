class StoreArticleSerializer < ActiveModel::Serializer
  type 'article'

  attributes :id, :store_id, :article_id, :text, :tag, :title, :icon, :excerpt, :category

  has_many :store_products
end
