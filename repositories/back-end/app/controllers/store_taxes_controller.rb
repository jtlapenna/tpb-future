class StoreTaxesController < ApplicationController
  before_action :set_store_tax, only: [:show, :update, :destroy]
  before_action :find_store
  before_action :find_tax, only: %i[show update]

  # GET /store_taxes
  def index
    @store_taxes = StoreTax.all

    render json: @store_taxes
  end

  # GET /store_taxes/1
  def show
    render json: @store_tax
  end

  # POST /store_taxes
  def create
    authorize StoreTax
    tax = @store.store_taxes.build(permitted_attributes(StoreTax))

    if tax.save
      render json: tax, status: :created
    else
      errors = tax.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /store_taxes/1
  def update
    authorize @tax
    if @tax.update(permitted_attributes(@tax))
      render json: @tax
    else
      errors = @tax.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  # DELETE /store_taxes/1
  def destroy
    @store_tax.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store_tax
      @store_tax = StoreTax.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def store_tax_params
      params.fetch(:store_tax, {})
    end

  def find_store
    @store = policy_scope(Store).find(params[:store_id])
  end

  def find_tax
    @tax = @store.store_taxes.find(params[:id])
  end
end
