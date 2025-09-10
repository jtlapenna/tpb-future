class KioskProductLayoutPolicy < ApplicationPolicy
  def show?
    user
  end

  def update?
    user
  end

  def permitted_attributes
    [
      :stylesheet,
      values: [
        :id, :link, :content, :product_layout_element_id, :_destroy,
        asset_attributes: %i[id url _destroy]
      ]
    ]
  end
end
