class ArticlesController < ApplicationController
  include Paged
  include Sortable

  before_action :find_article, only: %i[show update]

  def index
    authorize Article

    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";    

    articles = policy_scope(Article).page(page).per(page_size).order(order_fields).where('title ILIKE ?',q)

    render json: articles, meta: pagination_dict(articles)
  end

  def create
    authorize Article

    article = Article.new(permitted_attributes(Article))

    if article.save
      render json: article, status: :created
    else
      errors = article.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @article

    if @article.update(permitted_attributes(@article))
      render json: @article
    else
      errors = @article.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @article
    render json: @article
  end

  private

  def find_article
    @article ||= policy_scope(Article).find(params[:id])
  end
end
