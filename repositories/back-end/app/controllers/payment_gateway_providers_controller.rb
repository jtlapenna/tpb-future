class PaymentGatewayProvidersController < ApplicationController
  include Paged
  include Sortable
  include Searchable

  before_action :set_payment_gateway_provider, only: [:show, :update, :destroy]

  # GET /payment_gateway_providers
  def index
    @payment_gateway_providers = PaymentGatewayProvider.all
    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";
    @payment_gateway_providers = @payment_gateway_providers
                                    .page(page)
                                    .per(page_size)
                                    .order(order_fields)
                                    .where('payment_gateway_providers.name ILIKE ?', q)
    render json: @payment_gateway_providers,
           meta: pagination_dict(@payment_gateway_providers),
           each_serializer: PaymentGatewayProviderSerializer
  end

  # GET /payment_gateway_providers/1
  def show
    render json: @payment_gateway_provider
  end

  # POST /payment_gateway_providers
  def create
    @payment_gateway_provider = PaymentGatewayProvider.new(payment_gateway_provider_params)

    if @payment_gateway_provider.save
      render json: @payment_gateway_provider, status: :created, location: @payment_gateway_provider
    else
      render json: @payment_gateway_provider.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payment_gateway_providers/1
  def update
    if @payment_gateway_provider.update(payment_gateway_provider_params)
      render json: @payment_gateway_provider
    else
      render json: @payment_gateway_provider.errors, status: :unprocessable_entity
    end
  end

  # DELETE /payment_gateway_providers/1
  def destroy
    @payment_gateway_provider.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_gateway_provider
      @payment_gateway_provider = PaymentGatewayProvider.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def payment_gateway_provider_params
      params.require(:payment_gateway_provider).permit(:name, :fields)
    end
end
