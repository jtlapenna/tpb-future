class StoreProductsController < ApplicationController
  include Paged
  include Sortable
  include Searchable

  before_action :find_product, only: %i[show update destroy]
  before_action :find_store, only: %i[search index]

  def index
    authorize StoreProduct
    category_id = params[:store_category_id]
    tag = params[:tag]
    name = params[:name]
    product_id = params[:product_id]
    brand_id = params[:brand_id]
    unpublished = params[:unpublished] == 'true'
    published = params[:published] == 'true'
    without_promotions = params[:without_promotions]

    products = policy_scope(StoreProduct).includes([:brand, :store_category, product_variant: :brand])
    if without_promotions
      products = products.left_outer_joins(:store_product_promotions).where(store_product_promotions: {id: nil})
    end
    products = products.joins(:store).where(store_categories: { store_id: @store.id })
    products = products.where(store_category_id: category_id) if category_id.present?
    products = products.unpublished if unpublished
    products = products.published if published

    products = products.name_like(name) if name.present?
    if product_id.present?
      products = products.joins(:product_variant)
                         .merge(
                           ProductVariant.where(product_variants: { product_id: product_id })
                         )
    end

    products = products.joins(:product_variant) if brand_id.present?

    if brand_id.present?
      products = products
                 .where(product_variants: { brand_id: brand_id }, brand_id: nil)
                 .or(products.where(brand_id: brand_id))
    end

    products = products.deep_tagged_with(tag) if tag.present?

    if params[:q].present?
      numeric_filters = []
      numeric_filters << "store_category.id=#{category_id}" if category_id.present?
      numeric_filters << "product_id=#{product_id}" if product_id.present?
      numeric_filters << "brand_id=#{brand_id}" if brand_id.present?

      products = do_search(products, params[:q], numericFilters: numeric_filters)
    else
      products = products.page(page).per(page_size).order(order_fields)
    end

    each_serializer = minimal? ? StoreProductMinimalSerializer : StoreProductSerializer

    serializer_include = minimal? ? search_includes : full_includes

    render json: products,
           root: 'store_products',
           each_serializer: each_serializer,
           include: serializer_include, meta: pagination_dict(products)
  end

  def create
    authorize StoreProduct
    product = StoreProduct.new(permitted_attributes(StoreProduct))

    if product.save
      render json: product, include: full_includes, status: :created
    else
      errors = product.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @product
    if @product.update(permitted_attributes(@product))
      render json: @product, include: full_includes
    else
      errors = @product.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @product
    render json: @product, include: full_includes
  end

  def search
    authorize StoreProduct
    name = params[:name]
    product_variant_id = params[:product_variant_id]
    tag = params[:tag]

    products = @store.store_products.name_like(name)
    if product_variant_id.present?
      products = products.where(
        product_variant_id: product_variant_id
      )
    end

    products = products.deep_tagged_with(tag) if tag.present?

    case_sentence = 'COALESCE(store_products.name, product_variants.name, products.name)'

    products = products.select("
      store_products.id as id,
      store_products.sku as sku,
      store_products.stock as stock,
      store_products.store_category_id as store_category_id,
      store_products.product_variant_id as product_variant_id,
      store_products.brand_id as brand_id,
      store_products.status,
      #{case_sentence} as name
    ")
    products = products.includes(:store_category, :brand, product_variant: :brand)
                       .order('name asc')
                       .limit(15)

    render json: products, each_serializer: StoreProductMinimalSerializer, include: search_includes
  end

  def destroy
    authorize @product

    if @product.destroy
      render json: {}
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  private

  def full_includes
    [
      :store,
      :store_category,
      :brand,
      'product_variant.product',
      'product_variant.images',
      'product_variant.brand',
      'product_variant.video',
      'product_variant.attribute_values.attribute_def',
      'attribute_values.attribute_def.attribute_group',
      :product_values,
      :images,
      :own_images,
      :primary_image,
      :thumb_image,
      :video
    ]
  end

  def search_includes
    [
      'product_variant.brand',
      :store_category,
      :brand
    ]
  end

  def find_store
    @store ||= policy_scope(Store).find(params[:store_id])
  end

  def find_product
    @product ||= policy_scope(StoreProduct).find(params[:id])
  end

  def minimal?
    params[:minimal] == 'true'
  end
end
