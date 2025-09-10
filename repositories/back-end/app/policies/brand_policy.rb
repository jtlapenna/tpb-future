class BrandPolicy < ApplicationPolicy
  def index?
    user
  end

  def permitted_attributes
    [:name, :description, logo_attributes: %i[id url _destroy]]
  end
end
