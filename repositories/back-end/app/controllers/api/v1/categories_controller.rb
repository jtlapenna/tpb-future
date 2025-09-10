class Api::V1::CategoriesController < Api::V1::ApplicationController
  def index
    # categories = kiosk.store_categories.joins(:store_products).select("store_categories.id, store_categories.name, store_categories.order, store_categories.created_at, store_categories.updated_at, sum(store_products.stock) as total_stock").group(:id, :name, :order, :created_at, :updated_at).includes(:banner).order(order: :asc).uniq
    categories = kiosk.store_categories.includes(:banner).order(order: :asc).uniq

    render json: categories,
           root: 'categories',
           each_serializer: Api::V1::StoreCategorySerializer
  end
end
