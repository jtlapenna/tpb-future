class Api::V1::CatalogArticlesController < Api::V1::ApplicationController
  include Paged
  include Sortable

  def index
    articles = kiosk.store.store_articles.includes(article: :category)

    articles = articles.page(page).per(page_size).order(order_fields)

    render json: articles,
           each_serializer: Api::V1::StoreArticleSerializer,
           meta: pagination_dict(articles),
           minimal: minimal?
  end

  private

  def minimal?
    params[:minimal] == 'true'
  end
end
