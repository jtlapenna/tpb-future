class CustomersController < ApplicationController
  before_action :check_api_key, only: %i[search]

  def search
    customers = api_client.customers(nil, params[:customer_id])

    render json: { customers: customers }, status: :ok
  end

  protected

  def check_api_key
    unless params[:api_key].present?
      render json: { error: { message: 'API key is required' } }, status: :not_found and return
    end
  end

  def api_client
    @api_client ||= Leaflogix::ApiClient.new({ api_key: params[:api_key] })
  end
end
