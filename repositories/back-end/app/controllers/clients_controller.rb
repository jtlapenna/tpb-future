class ClientsController < ApplicationController
  include Paged
  include Sortable

  before_action :find_client, only: %i[show update]

  def index
    authorize Client

    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";   

    clients = policy_scope(Client).page(page).per(page_size).order(order_fields).where('name ILIKE ?',q)

    render json: clients, meta: pagination_dict(clients)
  end

  def create
    authorize Client
    client = Client.new(permitted_attributes(Client))

    if client.save
      render json: client, status: :created
    else
      errors = client.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @client
    if @client.update(permitted_attributes(@client))
      render json: @client
    else
      errors = @client.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @client
    render json: @client
  end

  private

  def find_client
    @client ||= policy_scope(Client).find(params[:id])
  end
end
