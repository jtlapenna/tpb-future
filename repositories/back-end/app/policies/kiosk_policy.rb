class KioskPolicy < ApplicationPolicy
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

  def update?
    user
  end

  def show?
    user
  end

  def clone?
    admin?
  end

    def permitted_attributes
    [
      :id, :stock,
      :name, :tag_list, :store_id,
      :sensor_method, :sensor_threshold, :rfid_sorting, :rfid_behavior, :location,
      :product_filter_criteria, :product_filter_value_type, :product_filter_value_id,
      rfid_products_attributes: %i[
        id rfid rfid_entity_type rfid_entity_id order _destroy
      ]
    ]
  end
end
