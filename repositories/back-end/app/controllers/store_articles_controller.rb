class StoreArticlesController < ApplicationController
  include Paged
  include Sortable

  before_action :store
  before_action :article, only: %i[show update destroy]

  def index
    authorize StoreArticle
    articles = store.store_articles
    articles = articles.page(page).per(page_size).order(order_fields)

    # Warning, Don't remove root, because an empty array is serialized as store_articles instead.
    render json: articles, meta: pagination_dict(articles), root: 'articles', include: []
  end

  def create
    authorize StoreArticle
    article = store.store_articles.build(article_params)

    if article.save
      render json: article, status: :created
    else
      errors = article.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize article
    if article.update(article_params)
      render json: article
    else
      errors = article.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize article

    render json: article, include: full_includes
  end

  def destroy
    authorize article

    article.destroy ? head(:no_content) : head(:unprocessable_entity)
  end

  def default_products
    authorize StoreArticle

    article = Article.find(params[:article_id])

    store_article = store.store_articles.build(article: article)

    includes = [
      :store_category,
      'product_variant.product'
    ]

    render json: store_article.products_for_catalog.includes(product_variant: :product),
           include: includes
  end

  private

  def store
    @store ||= policy_scope(Store).find(params[:store_id])
  end

  def article
    @article ||= store.store_articles.find(params[:id])
  end

  def article_params
    params.require(:article).permit(policy(StoreArticle).permitted_attributes)
  end

  def full_includes
    [
      'store_products.store_category',
      'store_products.product_variant.product',
      'store_products.images',
      'store_products.thumb_image'
    ]
  end
end
