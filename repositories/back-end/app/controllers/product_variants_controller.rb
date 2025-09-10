class ProductVariantsController < ApplicationController
  include Paged
  include Sortable
  include Searchable

  before_action :find_product, only: %i[show update tags]

  def index
    authorize ProductVariant
    product_id = params[:product_id]
    product_category_id = params[:product_category_id]
    brand_id = params[:brand_id]

    variants = policy_scope(ProductVariant)
               .joins(:product)
               .includes({ product: [:category] }, :attribute_values, :brand, :reviews, :images)

    variants = variants.where(product_id: product_id) if product_id.present?
    if product_category_id.present?
      variants = variants.joins(:product)
                         .where(
                           products: { category_id: product_category_id }
                         )
    end

    variants = variants.where(brand_id: brand_id) if brand_id.present?

    variants = if params[:q].present?
                 do_search(variants, params[:q])
               else
                 variants.page(page).per(page_size).order(order_fields)
               end

    render json: variants, root: 'product_variants', meta: pagination_dict(variants)
  end

  def create
    authorize ProductVariant
    product = ProductVariant.new(permitted_attributes(ProductVariant))

    if product.save
      render json: product, status: :created
    else
      errors = product.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @product
    if @product.update(permitted_attributes(@product))
      render json: @product
    else
      errors = @product.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @product
    includes = [
      'attribute_values.attribute_def.attribute_group',
      :brand,
      :category,
      :product,
      :images,
      :reviews,
      :video
    ]
    render json: @product, include: includes
  end

  def search
    authorize ProductVariant
    name = params[:name]

    variants = policy_scope(ProductVariant).order(order_fields).limit(15)
    variants = variants.name_like(name) if name.present?

    render json: variants, each_serializer: ProductVariantMinimalSerializer
  end

  def tags
    authorize @product
    render json: { tags: @product.tag_list }
  end

  private

  def find_product
    @product ||= policy_scope(ProductVariant).find(params[:id])
  end

  def order_fields(
    product_variants_table: 'product_variants',
    products_table: 'products',
    supports: ['name', 'sku', 'brand.name']
  )
    return { id: :desc } unless supports.include?(params[:sort_by])

    field = case params[:sort_by]
            when 'brand.name'
              "brands.name #{order_direction}"
            else
              { order_by.to_sym => order_direction.to_sym }
    end
  end
end
