class StoreCategoryTaxPolicy < ApplicationPolicy
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
    [:name, :value]
  end
end
