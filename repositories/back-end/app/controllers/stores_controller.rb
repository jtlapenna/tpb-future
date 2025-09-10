class StoresController < ApplicationController
  include Paged
  include Sortable

  before_action :find_store, only: %i[show update generate_token tax_customer_types get_inventory_types]

  def index
    authorize Store

    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";                            

    stores = policy_scope(Store).includes(:store_taxes,:store_categories,:client, :logo, settings: %i[background_media purchase_limits])
                                .page(page)
                                .per(page_size)
                                .order(order_fields).where('stores.name ILIKE ?',q)

    render json: stores, meta: pagination_dict(stores), include: store_includes
  end

  def create
    authorize Store
    store = Store.new(permitted_attributes(Store).merge(regenerate_jti: true))

    if store.save
      render json: store, status: :created, include: store_includes
    else
      errors = store.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @store

    if @store.update(permitted_attributes(@store))
      render json: @store, include: store_includes
    else
      errors = @store.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @store
    render json: @store, include: store_includes
  end

  def generate_token
    authorize @store
    @store.regenerate_jti = true
    @store.save!

    payload = @store.to_token_payload
    token = Knock::AuthToken.new(payload: payload).token
    render json: { jwt: token }, status: :created
  end

  def tax_customer_types
    authorize @store

    api_client = Leaflogix::ApiClient.new(@store.leaflogix_api_config)

    tax_customer_types = api_client.get_customer_types

    # only return the tax customer types that are Recreational or Medical
    tax_customer_types = tax_customer_types.select { |tax_customer_type| tax_customer_type['name'] == 'Recreational' || tax_customer_type['name'] == 'Medical' }

    render json: tax_customer_types, status: :ok
  end

  def get_inventory_data
    body = JSON.parse(request.body.read).transform_keys(&:to_sym)

    # Fetch inventory data from Blaze
    api_client = Blaze::ApiClient.new(body)
    inventory_data = api_client.get_inventory_types

    # if inventory_data includes :message, return the error message
    if inventory_data.include?(:message)
      render json: { message: inventory_data[:message] }, status: :unprocessable_entity
      return
    end

    # Filter active inventory data
    active_inventory_data = inventory_data
      .select { |inventory_item| inventory_item['active'] == true }
      .map { |inventory_item| { id: inventory_item['id'], name: inventory_item['name'], active: inventory_item['active'] } }

    render json: active_inventory_data, status: :ok
  end

  private

  def find_store
    @store ||= policy_scope(Store).find(params[:id])
  end

  def store_includes
    ['logo', 'client', 'settings.background_media', 'settings.purchase_limits', 'store_categories','store_taxes']
  end

  def api_client(config)
    @api_client ||= Leaflogix::ApiClient.new(config)
  end

end
