class StorePricesController < ApplicationController
  include Paged
  include Sortable

  before_action :find_store
  before_action :find_price, only: %i[show update]

  def index
    authorize StorePrice
    prices = @store.store_prices.page(page).per(page_size).order(order_fields)

    render json: prices, meta: pagination_dict(prices)
  end

  def create
    authorize StorePrice
    price = @store.store_prices.build(permitted_attributes(StorePrice))

    if price.save
      render json: price, status: :created
    else
      errors = price.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @price
    if @price.update(permitted_attributes(@price))
      render json: @price
    else
      errors = @price.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @price
    render json: @price
  end

  private

  def find_store
    @store = policy_scope(Store).find(params[:store_id])
  end

  def find_price
    @price = @store.store_prices.find(params[:id])
  end
end
