class AdConfigPolicy < ApplicationPolicy
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
      [
       :name, :kiosk_id, :kiosk_product_id, :brand_id, :use_brand_spotlight, asset_attributes: %i[id url _destroy]
      ]
    end
  end
  