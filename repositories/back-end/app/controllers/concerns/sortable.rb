module Sortable
  extend ActiveSupport::Concern

  def order_by
    params[:sort_by] || :id
  end

  def order_direction
    params[:sort_direction] == 'asc' ? :asc : :desc
  end

  def order_fields
    { order_by.to_sym => order_direction.to_sym }
  end
end
