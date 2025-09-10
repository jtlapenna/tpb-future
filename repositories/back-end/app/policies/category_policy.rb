class CategoryPolicy < ApplicationPolicy
  def index?
    user
  end

  def permitted_attributes
    [:name]
  end
end
