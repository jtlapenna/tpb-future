class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :text, :tag, :icon, :excerpt

  belongs_to :category
end
