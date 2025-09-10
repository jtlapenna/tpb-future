class StoreCategoriesController < ApplicationController
  include Paged
  include Sortable

  before_action :find_store
  before_action :find_category, only: %i[show update destroy]
  before_action :check_products, only: [:destroy]

  def index
    authorize StoreCategory

    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";                            

    categories = @store.store_categories.page(page).per(page_size).order(order_fields).where('name ILIKE ?',q)

    render json: categories, meta: pagination_dict(categories), include: ''
  end

  def create
    authorize StoreCategory
    category = @store.store_categories.build(permitted_attributes(StoreCategory))

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
      @category.store_products.touch_all

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

  def destroy
    authorize @category

    @category.destroy ? head(:ok) : head(:unprocessable_entity)
  end

  def categories_by_brand
    brand_id = params[:brand_id]
    store_id = params[:store_id]
    q = params[:q] != nil ? "%" + params[:q] + "%" : "%"

    categories = @store.store_categories
                       .joins(:store_products)
                       .joins("LEFT JOIN product_variants ON store_products.product_variant_id = product_variants.id")
                       .where(store_products: { store_id: store_id })
                       .where("store_products.brand_id = :brand_id OR product_variants.brand_id = :brand_id", brand_id: brand_id)
                       .where('store_products.stock > ?', 0)
                       .where('store_categories.name ILIKE ?', q)
                       .distinct
                       .page(page)
                       .per(page_size)
                       .order(order_fields)

    render json: categories, meta: pagination_dict(categories), include: ''
  end

  private

  def check_products
    if @category.store_products.count > 0
      errors = { category_not_empty: ['Can not delete a category with products'] }
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def find_store
    @store = policy_scope(Store).find(params[:store_id])
  end

  def find_category
    @category ||= @store.store_categories.find(params[:id])
  end
end
