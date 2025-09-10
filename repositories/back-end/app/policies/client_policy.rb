class ClientPolicy < ApplicationPolicy
  def show?
    user
  end

  def permitted_attributes
    [:name]
  end
end
