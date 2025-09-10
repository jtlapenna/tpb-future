class PaymentGatewaysController < ApplicationController
  include Paged
  include Sortable
  include Searchable

  before_action :find_store
  before_action :set_payment_gateway, only: [:show, :update, :destroy]
  
  # GET /payment_gateways
  def index
    @payment_gateways = @store.payment_gateways.all
    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";
    @payment_gateways = @payment_gateways
                          .joins(:payment_gateway_provider)
                          .page(page)
                          .per(page_size)
                          .order(order_fields)
                          .where('payment_gateway_providers.name ILIKE ? ', q)
    render json: @payment_gateways,
           meta: pagination_dict(@payment_gateways),
           each_serializer: PaymentGatewaySerializer
  end

  # GET /payment_gateways/1
  def show
    render json: @payment_gateway
  end

  # POST /payment_gateways
  def create
    @payment_gateway = @store.payment_gateways.new(payment_gateway_params)

    if @payment_gateway.save
      render json: @payment_gateway, status: :created
    else
      render json: @payment_gateway.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payment_gateways/1
  def update
    if @payment_gateway.update(payment_gateway_params)
      render json: @payment_gateway
    else
      render json: @payment_gateway.errors, status: :unprocessable_entity
    end
  end

  # DELETE /payment_gateways/1
  def destroy
    @payment_gateway.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_gateway
      @payment_gateway = @store.payment_gateways.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def payment_gateway_params
      params.require(:payment_gateway).permit(:store_id, :payment_gateway_provider_id, :projects, api_settings: {})
    end

    def find_store
      @store = policy_scope(Store).find(params[:store_id])        
    end
end
