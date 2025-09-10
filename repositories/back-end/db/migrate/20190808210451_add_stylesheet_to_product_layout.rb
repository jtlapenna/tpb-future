class AddStylesheetToProductLayout < ActiveRecord::Migration[5.2]
  def change
    add_column :product_layouts, :stylesheet, :text
  end
end
