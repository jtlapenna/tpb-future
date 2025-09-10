class AddWidthToProductLayoutElement < ActiveRecord::Migration[5.2]
  def change
    add_column :product_layout_elements, :width, :string
  end
end
