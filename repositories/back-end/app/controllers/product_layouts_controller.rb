class ProductLayoutsController < ApplicationController
  include Paged
  include Sortable

  before_action :find_layout, only: %i[show update]

  def index
    authorize ProductLayout
    layouts = policy_scope(ProductLayout).page(page).per(page_size).order(order_fields)

    render json: layouts, meta: pagination_dict(layouts), include: ''
  end

  def create
    authorize ProductLayout
    layout = ProductLayout.new(permitted_attributes(ProductLayout))

    if layout.save
      render json: layout, status: :created, include: product_layout_includes
    else
      errors = layout.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @layout
    if @layout.update(permitted_attributes(@layout))
      render json: @layout, include: product_layout_includes
    else
      errors = @layout.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @layout
    render json: @layout, include: product_layout_includes
  end

  private

  def find_layout
    @layout ||= policy_scope(ProductLayout).find(params[:id])
  end

  def product_layout_includes
    ['elements', 'tabs.elements']
  end
end
