class ProductLayoutPolicy < ApplicationPolicy
  def show?
    user
  end

  def permitted_attributes
    elements_attributes = %i[
      id element_type coord_x coord_y hint width _destroy
    ]

    [
      :name, :stylesheet,
      elements_attributes: elements_attributes,
      tabs_attributes: [
        :id, :name, :order, :_destroy,
        elements_attributes: elements_attributes
      ]
    ]
  end
end
