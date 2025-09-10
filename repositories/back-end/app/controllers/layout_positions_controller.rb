class LayoutPositionsController < ApplicationController
  include Paged
  include Sortable

  def index
    authorize LayoutPosition
    layout_positions = policy_scope(LayoutPosition).page(page).per(page_size).order(order_fields)

    render json: layout_positions, meta: pagination_dict(layout_positions)
  end
end
