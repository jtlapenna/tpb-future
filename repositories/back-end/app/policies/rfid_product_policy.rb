class RfidProductPolicy < ApplicationPolicy
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

  def permitted_attributes
    %i[
      rfid rfid_entity_id rfid_entity_type order
    ]
  end
end
