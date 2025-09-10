class KioskProductsController < ApplicationController
  include KioskRequired
  include Sortable
  include Searchable
  include Paged

  before_action :find_product, only: %i[show update destroy]

  after_action :verify_authorized
  after_action :verify_policy_scoped

  def index
    authorize KioskProduct

    category_id = params[:store_category_id]
    brand_id = params[:brand_id]
    product_id = params[:product_id]
    name = params[:name]
    tag = params[:tag]

    products = policy_scope(kiosk.kiosk_products)

    unless only_id?
      products = products.joins(store_product: { product_variant: [:product] })
                         .includes([
                                     :thumb_image, :store_category,
                                     store_product: :brand, product_variant: :brand
                                   ])
    end

    if category_id.present?
      products = products.where(
        store_products: { store_category_id: category_id }
      )
    end

    if brand_id.present?
      products = products
                 .where(
                   product_variants: { brand_id: brand_id }, store_products: { brand_id: nil }
                 )
                 .or(products.where(store_products: { brand_id: brand_id }))
    end

    if product_id.present?
      products = products
                 .merge(ProductVariant.where(product_variants: { product_id: product_id }))
    end

    products = products.merge(StoreProduct.name_like(name)) if name.present?

    products = products.merge(StoreProduct.deep_tagged_with(tag)) if tag.present?

    if params[:q].present?
      numeric_filters = []
      numeric_filters << "store_category.id=#{category_id}" if category_id.present?

      products = do_search(products, params[:q], numericFilters: numeric_filters)
    else
      products = products.page(page).per(page_size).order(order_fields)
    end

    each_serializer = only_id? ? KioskProductCompactSerializer : KioskProductMinimalSerializer

    render json: products,
           include: minimal_includes,
           root: 'kiosk_products',
           each_serializer: each_serializer,
           meta: pagination_dict(products)
  end

  def create
    authorize KioskProduct

    products = params[:kiosk_products].map do |attributes|
      StoreProduct.find(attributes[:store_product_id]).touch
      KioskProduct.new(
        {
          store_product_id: attributes[:store_product_id],
          featured: attributes[:featured]
        }.merge(kiosk: kiosk)
      )
    end

    begin
      KioskProduct.transaction { products.each(&:save!) }

      head :created
    rescue StandardError => e
      Rails.logger.error e
      errors = products.reject(&:valid?).map(&:errors).as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @kiosk_product

    render json: @kiosk_product, include: full_includes
  end

  def update
    authorize @kiosk_product

    if @kiosk_product.update(permitted_attributes(@kiosk_product))
      StoreProduct.find(@kiosk_product.store_product_id).touch
      render json: @kiosk_product, include: full_includes
    else
      errors = @kiosk_product.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @kiosk_product
    StoreProduct.find(@kiosk_product.store_product_id).touch
    @kiosk_product.destroy ? head(:no_content) : head(:unprocessable_entity)
  end

  def search
    authorize KioskProduct
    name = params[:name]

    products = @kiosk.kiosk_products.joins(:store_product).merge(
      StoreProduct.name_like(name)
    )

    case_sentence = 'COALESCE(store_products.name, product_variants.name, products.name)'

    products = products.select("
      kiosk_products.id as id,
      kiosk_products.featured as featured,
      store_products.id as store_product_id,
      store_products.sku as sku,
      store_products.stock as stock,
      store_products.store_category_id as store_category_id,
      store_products.product_variant_id as product_variant_id,
      store_products.brand_id as brand_id,
      #{case_sentence} as name
    ")

    category_id = params[:store_category_id]

    if category_id.present?
      products = products.where(
        store_products: { store_category_id: category_id }
      )
    end

    exclude_zero = params[:exclude_zero]

    if exclude_zero
      products = products                     
                     .includes(
                         store_product: [
                             :store_category, :brand, { product_variant: :brand }
                         ]
                     )
                     .where('store_products.stock > ?',0)
                     .order('name asc')
                     .limit(15)
    else
      products = products
                     .includes(
                         store_product: [
                             :store_category, :brand, { product_variant: :brand }
                         ]
                     )
                     .order('name asc')
                     .limit(15)
    end

    render json: products, each_serializer: KioskProductMinimalSerializer, include: search_includes
  end

  def compact
    authorize KioskProduct

    products = policy_scope(kiosk.kiosk_products)

    products = products.page(page).per(page_size).order(order_fields)

    render json: products,
           root: 'kiosk_products',
           each_serializer: KioskProductCompactSerializer,
           meta: pagination_dict(products)
  end

  def new
    authorize KioskProduct

    products = policy_scope(kiosk.kiosk_products)

    products = policy_scope(StoreProduct).includes([:brand, :store_category, product_variant: :brand])  
    products = products.joins(:store).where(store_categories: { store_id: kiosk.store_id })
    products = products.joins("LEFT OUTER JOIN kiosk_products ON kiosk_products.store_product_id = store_products.id AND kiosk_products.kiosk_id = #{kiosk.id}").
                where('kiosk_products.id IS NULL')        

    category_id = params[:store_category_id]
    if category_id.present?
      products = products.where(
        store_products: { store_category_id: category_id }
      )
    end
    if params[:q].present?
      numeric_filters = []      

      products = do_search(products, params[:q], numericFilters: numeric_filters)
    else
      products = products.page(page).per(page_size).order(order_fields)
    end    

    render json: products,
           root: 'store_products',
           each_serializer: StoreProductMinimalSerializer,
           meta: pagination_dict(products)             
  end 

  def new_categories
    authorize KioskProduct

    products = policy_scope(kiosk.kiosk_products)

    products = policy_scope(StoreProduct).includes([:brand, :store_category, product_variant: :brand])
    products = products.joins(:store).where(store_categories: { store_id: kiosk.store_id })
    products = products.joins("LEFT OUTER JOIN kiosk_products ON kiosk_products.store_product_id = store_products.id AND kiosk_products.kiosk_id = #{kiosk.id}").
                where('kiosk_products.id IS NULL')    

    categoriesIds = products.pluck('store_category_id')

    categories = policy_scope(StoreCategory).where(:id => categoriesIds)    

    render json: categories,
           root: 'store_categories'           
  end 

  private

  def find_product
    @kiosk_product ||= policy_scope(kiosk.kiosk_products).find(params[:id])
  end

  def search_includes
    [
      'store_product.product_variant.brand',
      'store_product.store_category',
      'store_product.brand'
    ]
  end

  def full_includes
    [
      store_product: [
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
    ]
  end

  def minimal_includes
    [
      store_product: [
        :brand,
        :store,
        'product_variant.product',
        'product_variant.images',
        'product_variant.brand',
        'product_variant.video',
        'product_variant.attribute_values.attribute_def',
        :store_category,
        :thumb_image
      ]
    ]
  end

  def order_fields(
    product_variants_table: 'product_variants',
    products_table: 'products',
    supports: %w[name stock brand sku featured]
  )
    return { id: :desc } unless supports.include?(params[:sort_by])

    if %w[name featured].include?(params[:sort_by])
      by_name = <<-SQL
        COALESCE(
          store_products.name,
          #{product_variants_table}.name,
          #{products_table}.name
        )
      SQL
    end

    field = case params[:sort_by]
            when 'name'
              Arel.sql "#{by_name} #{order_direction}"
            when 'stock'
              Arel.sql "store_products.stock #{order_direction}"
            when 'sku'
              Arel.sql "store_products.sku #{order_direction}"
            when 'brand'
              Arel.sql "brands.name #{order_direction}"
            when 'featured'
              Arel.sql "featured #{order_direction} NULLS LAST, #{by_name}"
            else
              { order_by.to_sym => order_direction.to_sym }
    end
  end

  def only_id?
    params[:only_id] == 'true'
  end  

  def minimal?
    params[:minimal] == 'true'
  end   

  def store_product_full_includes
    [
      store_product: [
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
    ]
  end

  def store_product_search_includes
    [
      'store_product.product_variant.brand',
      'store_product.store_category',
      'store_product.brand'
    ]
  end
end
