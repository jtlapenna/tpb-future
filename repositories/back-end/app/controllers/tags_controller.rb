class TagsController < ApplicationController
  include Paged
  include Sortable

  before_action do
    self.namespace_for_serializer = ActsAsTaggableOn::Tag
  end

  def index
    authorize ActsAsTaggableOn::Tag
    q = params[:q]
    scoped = if params[:kiosk_id].present?
               policy_scope(Kiosk).find(params[:kiosk_id]).products_tags
             else
               ActsAsTaggableOn::Tag.all
             end

    tags = scoped.order(order_fields)
    tags = tags.name_like(q) if q.present?

    render json: tags, root: 'tags'
  end

  private

  def order_by
    :name
  end

  def order_direction
    :asc
  end
end
