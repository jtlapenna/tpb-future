class AttributeGroupPolicy < ApplicationPolicy
  def index?
    user
  end

  def permitted_attributes
    %i[name group_type order]
  end
end
