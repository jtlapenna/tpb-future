class StoreArticle < ApplicationRecord
  belongs_to :article
  belongs_to :store

  has_and_belongs_to_many :store_products

  validates :article_id, uniqueness: {
    scope: [:store_id], message: 'article is already used in store'
  }

  delegate :title, :tag, :text, :icon, :excerpt, :category, to: :article

  scope :owner, lambda { |owner|
    joins(:store)
      .merge(Store.owner(owner))
  }

  def products_for_catalog
    store_products.exists? ? store_products.published : default_products
  end

  private

  def default_products
    products_by_tags = store.store_products.deep_tagged_with(tag) if tag

    if category && store.store_categories.name_equal(category.name).exists?
      products_by_category = store.store_products.with_store_category(category)
    elsif category
      products_by_category = store.store_products.with_category_product(category)
    end

    default_products = StoreProduct.where(id: products_by_tags)
                                   .or(StoreProduct.where(id: products_by_category))

    StoreProduct.published
                .where(id: default_products)
                .order(id: :asc)
                .limit(10)
  end
end

# == Schema Information
#
# Table name: store_articles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint
#  store_id   :bigint
#
# Indexes
#
#  index_store_articles_on_article_id  (article_id)
#  index_store_articles_on_store_id    (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (store_id => stores.id)
#
