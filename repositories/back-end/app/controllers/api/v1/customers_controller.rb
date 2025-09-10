class Api::V1::CustomersController < Api::V1::ApplicationController
  include ExternalApiBridge

  before_action :find_client
  before_action :require_client
  before_action :client_support_creation, only: :create

  def index
    render json: { customers: @customer_client.all(index_params) }
  end

  def create
    customer = @customer_client.create!(create_params)

    render json: { customer: customer }, status: :created
  end

  private

  def require_client
    render_method_not_allowed if @customer_client.blank?
  end

  def client_support_creation
    render_method_not_allowed unless @customer_client.respond_to?(:create!)
  end

  def find_client
    @customer_client = kiosk.store.customer_client
  end

  def index_params
    params.permit(:catalog_id, :first_name, :last_name, :phone, :email, :driver_license, :birthday).each_value { |value| value.try(:strip!) }.to_h
  end

  def create_params
    params.require(:customer).permit(
      :first_name, :last_name, :gender, :birthday,
      :email, :phone, :drivers_license, :notes
    ).to_h
  end

  def render_method_not_allowed
    message = I18n.t 'errors.not_allowed', scope: 'integration', default: 'method not allowed'
    render(
      json: { status: 405, message: message },
      status: :method_not_allowed
    )
  end
end
