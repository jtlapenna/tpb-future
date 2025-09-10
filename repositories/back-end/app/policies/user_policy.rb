class UserPolicy < ApplicationPolicy
  def show?
    admin? || user == record
  end

  def update?
    admin? || user == record
  end

  def permitted_attributes
    %i[name email password password_confirmation client_id]
  end
end
