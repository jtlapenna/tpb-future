class AttributeGroupsController < ApplicationController
  include Paged
  include Sortable

  before_action :find_group, only: %i[show update destroy]

  def index
    authorize AttributeGroup

    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";                            

    groups = policy_scope(AttributeGroup).includes(:attribute_defs)
                                         .page(page).per(page_size).order(order_fields).where('name ILIKE ?',q)

    render json: groups, meta: pagination_dict(groups), include: includes
  end

  def create
    authorize AttributeGroup

    group = AttributeGroup.new(permitted_attributes(AttributeGroup))

    if group.save
      render json: group, status: :created, include: includes
    else
      errors = group.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @group

    if @group.update(permitted_attributes(@group))
      render json: @group, include: includes
    else
      errors = @group.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @group
    render json: @group, include: includes
  end

  def destroy
    authorize @group

    if @group.destroy
      render json: {}
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  private

  def includes
    default_includes = []
    default_includes << :attribute_defs if params[:include_attr_def] == 'true'
    default_includes
  end

  def find_group
    @group ||= policy_scope(AttributeGroup).find(params[:id])
  end
end
