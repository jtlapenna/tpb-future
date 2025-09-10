class ProductsController < ApplicationController
  include Paged
  include Sortable
  include Searchable

  before_action :find_product, only: %i[show update tags]

  def index
    authorize(Product)
    category = params[:category_id]
    name = params[:name]
    brand = params[:brand_id]

    products = policy_scope(Product).joins(:category)
                                    .includes(:category, :attribute_values)

    products = products.where(category_id: category) if category.present?
    products = products.where('products.name ILIKE :name', name: "%#{name}%") if name.present?
    if brand.present?
      products = products.joins(:product_variants)
                         .where(product_variants: { brand_id: brand })
    end

    products = if params[:q].present?
                 do_search(products, params[:q])
               else
                 products.page(page).per(page_size).order(order_fields)
               end

    render json: products, root: 'products', meta: pagination_dict(products)
  end

  def create
    authorize(Product)
    product = Product.new(permitted_attributes(Product))

    if product.save
      render json: product, status: :created
    else
      errors = product.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize(@product)
    if @product.update(permitted_attributes(@product))
      render json: @product
    else
      errors = @product.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize(@product)
    render json: @product, include: [
      'attribute_values.attribute_def.attribute_group',
      :category,
      :images,
      :reviews,
      :video
    ]
  end

  def search
    authorize(Product)
    name = params[:name]

    products = policy_scope(Product)
               .includes(:category)
               .order(order_fields)
               .limit(params[:per_page] || 15)

    products = products.name_like(name) if name.present?

    render json: products, each_serializer: ProductMinimalSerializer
  end

  def tags
    render json: { tags: @product.tag_list }
  end

  private

  def find_product
    @product ||= policy_scope(Product)
                 .joins(:category)
                 .includes(:category, attribute_values: { attribute_def: :attribute_group })
                 .find(params[:id])
  end
end
