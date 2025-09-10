class StoreSyncsController < ApplicationController
  before_action :find_sync, only: %i[show sync_item finish]
  before_action :ensure_parser, only: [:create]

  rescue_from ActionController::ParameterMissing, with: :unprocessable_entity
  rescue_from Treez::TreezError, with: :unprocessable_entity

  def create
    authorize StoreSync
    # result = parser.parse
    #
    # if result[:errors].blank?
    #   sync = result[:sync]
    #   sync.process_items
    # render json: sync.reload, status: :created
    # else
    #   render json: { errors: result[:errors].as_json }, status: :unprocessable_entity
    # end

    StoreSyncJob.perform_later(params[:store_id])
    render json: {message: 'FINISHED'}, status: :created
  end

  def show
    authorize @sync
    render json: @sync
  end

  def sync_item
    authorize @sync
    begin
      item = @sync.store_sync_items.find params[:store_sync_item_id]
      if item.to_confirm? || item.unmatched?
        item.product_variant_id = params[:product_variant_id]

        if params[:store_product_id].present?
          item.store_product_id = params[:store_product_id]

          item.update_store_product!
        else
          item.store_category_id = params[:store_category_id]

          item.create_store_product!
        end
      end

      render json: @sync.reload
    rescue ActiveRecord::RecordInvalid => e
      render json: {errors: [e.message]}, status: :unprocessable_entity
    end
  end

  def finish
    authorize @sync
    begin
      @sync.finished!
      render json: :ok
    rescue StandardError => e
      render json: {error: e.message}, status: :unprocessable_entity
    end
  end

  private

  def parser
    @parser ||= sync_params[:file] ? store.csv_parser(sync_params[:file]) : store.api_parser
  end

  def ensure_parser
    render json: {}, status: :unprocessable_entity unless parser
  end

  def store
    @store ||= policy_scope(Store).find(params[:store_id])
  end

  def sync_params
    params.permit(:file)
  end

  def find_sync
    @sync ||= policy_scope(StoreSync).find(params[:id])
  end
end
