class StoreSyncPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.owner(user)
      end
    end
  end

  def create?
    user
  end

  def sync_item?
    user
  end

  def show?
    user
  end

  def finish?
    user
  end
end
