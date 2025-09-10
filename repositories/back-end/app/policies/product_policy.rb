class ProductPolicy < ApplicationPolicy
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
      :name, :category_id, :description, :tag_list, :is_full_screen,
      attribute_values_attributes: %i[attribute_def_id value id _destroy],
      video_attributes: %i[id url _destroy],
      images_attributes: %i[id url _destroy],

      reviews_attributes: %i[id user rate text _destroy]
    ]
  end
end
