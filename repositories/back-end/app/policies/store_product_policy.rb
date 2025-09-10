class StoreProductPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.owner(user)
      end
    end
  end

  def search?
    user
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

  def permitted_attributes_for_update
    if user.admin? || !record.store.api_type
      all_attrs
    else # client with api sync can't update sku
      all_attrs - [:sku]
    end
  end

  def permitted_attributes_for_create
    all_attrs
  end

  private

  def all_attrs
    [
      :name, :store_category_id, :product_variant_id, :weight,
      :tag_list, :description, :stock, :override_tags,
      :primary_image_id, :primary_image_url, :thumb_image_id,
      :thumb_image_url, :sku, :rfid, :brand_id,
      :share_email_template, :share_sms_template, :status, :latest_update_source, :latest_update_token, :is_medical_only, :is_full_screen,
      product_values_attributes: %i[name value id _destroy],
      video_attributes: %i[id url _destroy],
      attribute_values_attributes: %i[attribute_def_id value id _destroy],
      own_images_attributes: %i[id url destroy],
      image_ids: []
    ]
  end
end
