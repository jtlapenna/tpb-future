class KioskProductPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.joins(:kiosk).merge(Kiosk.owner(user))
      end
    end
  end

  def index?
    user
  end

  def create?
    user
  end

  def show?
    admin? || (user && record&.store&.client_id == user.client_id)
  end

  def search?
    index?
  end

  def new_categories?
    new?
  end

  def compact?
    index?
  end

  def update?
    admin? || (user && record&.store&.client_id == user.client_id)
  end

  def destroy?
    admin? || (user && record&.store&.client_id == user.client_id)
  end

  def permitted_attributes
    %i[store_product_id featured]
  end
end
