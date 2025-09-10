class AttributeDefPolicy < ApplicationPolicy
  def show?
    user
  end

  def index?
    user
  end

  def permitted_attributes
    [
      :name, :attribute_group_id, :restricted,
      values: []
    ]
  end
end
