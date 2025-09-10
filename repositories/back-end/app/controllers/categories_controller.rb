class CategoriesController < ApplicationController
  include Paged
  include Sortable

  before_action :find_category, only: %i[show update]

  def index
    authorize Category

    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";                            

    categories = policy_scope(Category).page(page).per(page_size).order(order_fields).where('name ILIKE ?',q)

    render json: categories, meta: pagination_dict(categories)
  end

  def create
    authorize Category
    category = Category.new(permitted_attributes(Category))

    if category.save
      render json: category, status: :created
    else
      errors = category.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @category
    if @category.update(permitted_attributes(@category))
      render json: @category
    else
      errors = @category.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @category
    render json: @category
  end

  private

  def find_category
    @category ||= policy_scope(Category).find(params[:id])
  end
end
