class TagInfosController < ApplicationController
  include Paged
  include Sortable

  before_action :find_tag_info, only: %i[show update destroy]

  def index
    authorize TagInfo
    tags = policy_scope(TagInfo).page(page).per(page_size).order(order_fields)

    render json: tags, meta: pagination_dict(tags)
  end

  def create
    authorize TagInfo
    tag_info = TagInfo.new(permitted_attributes(TagInfo))

    if tag_info.save
      render json: tag_info, status: :created
    else
      errors = tag_info.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @tag_info
    if @tag_info.update(permitted_attributes(@tag_info))
      render json: @tag_info
    else
      errors = @tag_info.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @tag_info
    render json: @tag_info
  end

  def destroy
    authorize @tag_info
    if @tag_info.destroy
      render json: {}
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  private

  def order_by
    params[:sort_by] || :tag
  end

  def order_direction
    params[:sort_direction] || :asc
  end

  def find_tag_info
    @tag_info ||= policy_scope(TagInfo).find(params[:id])
  end
end
