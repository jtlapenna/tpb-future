class StoreCategoryTaxesController < ApplicationController
  before_action :set_store_category_tax, only: [:show, :update, :destroy]
  before_action :find_store_category
  before_action :find_tax, only: %i[show update]

  # GET /store_category_taxes
  def index
    @store_category_taxes = StoreCategoryTax.all

    render json: @store_category_taxes
  end

  # GET /store_category_taxes/1
  def show
    render json: @store_category_tax
  end

  # POST /store_category_taxes
  def create
    authorize StoreCategoryTax
    tax = @store_category.store_category_taxes.build(permitted_attributes(StoreCategoryTax))

    if tax.save
      render json: tax, status: :created
    else
      errors = tax.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /store_category_taxes/1
  def update
    authorize @tax
    if @tax.update(permitted_attributes(@tax))
      render json: @tax
    else
      errors = @tax.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  # DELETE /store_category_taxes/1
  def destroy
    @store_category_tax.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store_category_tax
      @store_category_tax = StoreCategoryTax.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def store_category_tax_params
      params.fetch(:store_category_tax, {})
    end

  def find_store_category
    @store_category = policy_scope(StoreCategory).find(params[:store_category_id])
  end

  def find_tax
    @tax = @store_category.store_category_taxes.find(params[:id])
  end
end
