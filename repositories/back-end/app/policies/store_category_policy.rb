class StoreCategoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.owner(user)
      end
    end
  end

  def index?
    user
  end

  def create?
    user
  end

  def update?
    user
  end

  def show?
    user
  end

  def permitted_attributes
    [
      :name, :order,
      banner_attributes: %i[id url _destroy]
    ]
  end
end
