class AttributeDefsController < ApplicationController
  include Paged
  include Sortable

  before_action :find_attribute, only: %i[show update destroy]

  def index
    authorize AttributeDef
    group_id = params[:attribute_group_id]
    without_group = params[:without_group]

    attributes = policy_scope(AttributeDef)
                 .includes(:attribute_group)
                 .page(page).per(page_size).order(order_fields)

    attributes = attributes.where(attribute_group_id: group_id) if group_id.present?
    attributes = attributes.where(attribute_group_id: nil) if without_group.present?

    render json: attributes, meta: pagination_dict(attributes)
  end

  def create
    authorize AttributeDef

    attribute_def = AttributeDef.new(permitted_attributes(AttributeDef))

    if attribute_def.save
      render json: attribute_def, status: :created
    else
      errors = attribute_def.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @attribute_def

    if @attribute_def.update(permitted_attributes(@attribute_def))
      render json: @attribute_def
    else
      errors = @attribute_def.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @attribute_def
    render json: @attribute_def
  end

  def destroy
    authorize @attribute_def

    if @attribute_def.destroy
      render json: {}
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  private

  def find_attribute
    @attribute_def ||= policy_scope(AttributeDef).find(params[:id])
  end
end
