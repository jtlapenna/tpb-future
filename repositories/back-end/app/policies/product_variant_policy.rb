class ProductVariantPolicy < ApplicationPolicy
  def index?
    user
  end

  def show?
    user
  end

  def search?
    user
  end

  def tags?
    user
  end

  def permitted_attributes
    [
      :name, :product_id, :brand_id, :description, :tag_list, :sku, :override_tags,
      attribute_values_attributes: %i[attribute_def_id value id _destroy],
      video_attributes: %i[id url _destroy],
      reviews_attributes: %i[id user rate text _destroy],
      image_ids: []
    ]
  end
end
