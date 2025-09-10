class ProductLayoutElementSerializer < ActiveModel::Serializer
  attributes :id, :element_type, :coord_x, :coord_y, :hint, :width
end
