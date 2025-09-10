class StoreProductPromotionPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.admin?
          scope
        else
          scope.joins(:store_product).merge(StoreProduct.owner(user))
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
  
    def permitted_attributes
      [:promotion]
    end
  end
  