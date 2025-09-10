class ImagePolicy < ApplicationPolicy
  def upload_request?
    user
  end

  def destroy?
    user
  end
end
