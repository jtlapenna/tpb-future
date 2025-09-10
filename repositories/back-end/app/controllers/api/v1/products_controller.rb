class Api::V1::ProductsController < Api::V1::ApplicationController
  include Paged
  include Sortable
  include Searchable

  before_action :find_product, only: %i[show tags reviews similars share]

  def index
    category_id = params[:category_id]
    brand_id = params[:brand_id]
    tag = params[:tagged_with]
    with_rfid = params[:with_rfid]
    exclude_zero = params[:exclude_zero]
    featured_product = params[:featured_product]

    products = KioskProduct.all.merge(
      StoreProduct.published
    ).includes(store_product_includes).preload(store_product_preloads)

    from_date = params[:max_date]

    products = products
                .joins(store_product: { product_variant: [:product] })
                .where(kiosk_id: kiosk.id)

    products = products.joins(:rfid_products) if /true|1/i.match(with_rfid)

    if exclude_zero == '1'
      products = products
                  .where('store_products.stock > ?', 0)
    end

    if featured_product == 'true'
      products = products
                .where(featured: true)
    end

    products = products.where('store_products.updated_at > ?', from_date.to_time + 1) if from_date.present?

    if category_id.present?
      products = products
                  .where(store_products: { store_category_id: category_id })
    end

    if brand_id.present?
      products = products
                  .where(store_products: {
                          product_variants: { brand_id: brand_id },
                          brand_id: nil
                        })
                  .or(products.where(store_products: { brand_id: brand_id }))
    end

    products = products.merge(StoreProduct.deep_tagged_with(tag)) if tag.present?

    if params[:q].present?
      numeric_filters = []
      numeric_filters << "kiosk_id=#{kiosk.id}"
      numeric_filters << "store_category.id=#{category_id}" if category_id.present?
      numeric_filters << "brand_id=#{brand_id}" if brand_id.present?

      products = do_search(products, params[:q], numericFilters: numeric_filters)
    else
      if params[:featured_tags].present?
        products = products.merge(
          StoreProduct.by_tag_relevance(params[:featured_tags])
        )
      end
      products = products.page(page).per(page_size).order(order_fields)
    end

    render json: products.uniq,
            root: 'products',
            include_attribute_values: true,
            each_serializer: Api::V1::KioskProductSerializer,
            meta: pagination_dict(products),
            include: serializer_includes
  end

  def minimal
    exclude_zero = params[:exclude_zero]

    products = kiosk.kiosk_products.joins(:store_product).merge(
      StoreProduct.published
        .where(store_id: kiosk.store_id)
    ).minimal

    if exclude_zero == '1'
      products = products
                  .where('store_products.stock > ?', 0)
    end

    from_date = params[:max_date]

    products = products.where('store_products.updated_at > ?', from_date.to_time + 1) if from_date.present?

    render json: products,
            root: 'products',
            each_serializer: Api::V1::KioskProductMinimalSerializer  
  end

  def maximal
    exclude_zero = params[:exclude_zero]

    products = kiosk.kiosk_products.joins(:store_product).merge(
      StoreProduct.where(store_id: kiosk.store_id)
    )

    if exclude_zero == '1'
      products = products
                  .where('store_products.stock > ?', 0)
    end

    from_date = params[:max_date]

    products = products.where('store_products.updated_at > ?', from_date.to_time + 1) if from_date.present?
    products = products.includes([:brand, :store_category, :primary_image, :thumb_image, :product_values, :images, :store_category_taxes, :store_taxes, :store, :kiosk, :store_taxes, :video, :product_variant, :tags, :rfid_products, store_product: [:store_product_promotions, :images, :own_images, { brand: :logo }]])

    products = products.page(page).per(page_size)
    render json: products.uniq,
            root: 'products',
            include_attribute_values: true,
            each_serializer: Api::V1::KioskProductSerializer,
            meta: pagination_dict(products),
            include: serializer_includes  
  end

  def check_products_availability
    store_id = params[:store_id]
    deleted_sku_logs = DuplicatedSkuDeletedLog.where(store_id: store_id).where('created_at > ?', 24.hours.ago)
    deleted_sku_logs = deleted_sku_logs.map { |log| { id: log.deleted_store_product_id, deleted_sku: log.deleted_sku } }

    render json: { data: deleted_sku_logs }
  end

  def check_products_expired_status
    kiosk_id = params[:kiosk_id]
    store_id = params[:store_id]
    products = params[:products]

    expired_products = []

    products.each do |product|
      store_product = StoreProduct.where(store_id: store_id, id: product[:id]).first
      expired_at = DateTime.parse(product[:expired_at])
      last_updated_at = DateTime.parse(product[:last_updated_at])

      if store_product.nil?
        ExpiredKioskProduct.create!(store_id: store_id, kiosk_id: kiosk_id, store_product_id: product[:id], expired_at: expired_at, last_updated_at: last_updated_at)
        expired_products << { id: product[:id], status: 'deleted' }
      else
        if store_product.status == 'published' && store_product.stock > 0
          expired_products << { id: product[:id], status: 'published', store_product_promotions: store_product.store_product_promotions, stock: store_product.stock, is_medical_only: store_product.is_medical_only }
        elsif store_product.status == 'unpublished' || store_product.stock == 0
          ExpiredKioskProduct.create!(store_id: store_id, kiosk_id: kiosk_id, store_product_id: product[:id], expired_at: expired_at, last_updated_at: last_updated_at)
          expired_products << { id: product[:id], status: store_product.status , promotion: [], stock: store_product.stock }
        end
      end
    end

    render json: { data: expired_products }
  end

  def show
    # Preload layout
    ActiveRecord::Associations::Preloader.new.preload(
      @product, product_layout_values: [:asset, { product_layout_element: :source }]
    )

    render json: @product,
            root: 'product',
            include_attribute_values: true,
            include_layout: true,
            include: serializer_includes  

    # results = KioskProduct.find_by_id(params[:id], params[:catalog_id])
    # render json: results.to_json
  end

  def tags
    render json: TagInfo.where(tag: @product.tag_list),
            root: 'tags',
            each_serializer: Api::V1::TagSerializer
  end

  def reviews
    render json: @product.merged_reviews.sort_by(&:created_at).reverse,
           root: 'reviews',
           each_serializer: Api::V1::ReviewSerializer
  end

  def similars
    products = kiosk.kiosk_products.joins(:store_product).merge(
      StoreProduct.published.similar_to(@product.store_product).order(similar_order_fields)
    ).joins(store_product: { product_variant: [:product] })
                    .page(page)
                    .per(page_size)

    if minimal?
      response = {
        products: products.pluck(:store_product_id),
        meta: pagination_dict(products)
      }
      return render json: response
    end

    products = products.includes(store_product_includes).preload(store_product_preloads)

    render json: products,
            root: 'products',
            each_serializer: Api::V1::KioskProductSerializer,
            meta: pagination_dict(products),
            include: serializer_includes  
  end

  def share
    email = params.dig(:share, :email)
    phone = params.dig(:share, :phone)

    ProductsMailer.share(@product.store_product, email).deliver_now if email.present?
    ShareProductTextMessageJob.perform_now(@product.store_product, phone) if phone.present?

    if email || phone
      render json: :ok
    else
      render json: { error: { message: 'email and phone not present' } }, status: :bad_request
    end
  end

  private

  def find_product
    @product ||= kiosk.kiosk_products.joins(:store_product).merge(
      StoreProduct.published
    ).find_by!(store_product_id: params[:id])  
  end

  def store_product_includes
    [
      :store,
      :rfid_products,
      :product_values,
      :primary_image,
      :thumb_image,
      :store_category,
      :store,
      { product_variant: { brand: :logo } },
      { store_product: [:images, :own_images, { brand: :logo }] }
    ]
  end

  def store_product_preloads
    [
      {
        product_variant: [{ product: %i[tags video] }, :tags, :video],
        store_product: %i[tags video]
      }
    ]
  end

  def serializer_includes
    [
      'catalog_category.banner',
      'taxes',
      'brand.logo',
      'images',
      'primary_image',
      'product_values',
      'thumb_image',
      'video',
      'store',
      'store_product_promotions'
    ]
  end

  def similar_order_fields
    order_fields supports: %w[name stock],
                 product_variants_table: 'product_variants_store_products',
                 products_table: 'products_product_variants'
  end

  def order_fields(
    product_variants_table: 'product_variants',
    products_table: 'products',
    supports: %w[name stock brand]
  )
    return { id: :desc } unless supports.include?(params[:sort_by])

    by_name = <<-SQL
      COALESCE(
        store_products.name,
        #{product_variants_table}.name,
        #{products_table}.name
      ) #{order_direction}
    SQL

    field = case params[:sort_by]
            when 'name'
              Arel.sql by_name
            when 'brand'
              Arel.sql "brands.name #{order_direction}"
            else
              { order_by.to_sym => order_direction.to_sym }
    end
  end

  def minimal?
    params[:minimal] == 'true'
  end
end
