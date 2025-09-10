class AssetPolicy < ApplicationPolicy
  def upload_request?
    record == Image ? user : admin?
  end

  def destroy?
    user || admin
  end
end
