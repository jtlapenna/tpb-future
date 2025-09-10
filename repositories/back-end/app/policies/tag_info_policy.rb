class TagInfoPolicy < ApplicationPolicy
  def permitted_attributes
    %i[tag description]
  end
end
