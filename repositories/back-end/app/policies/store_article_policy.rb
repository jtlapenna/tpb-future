class StoreArticlePolicy < ApplicationPolicy
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

  def destroy?
    user
  end

  def default_products?
    user
  end

  def permitted_attributes
    [
      :article_id,
      store_product_ids: []
    ]
  end
end
