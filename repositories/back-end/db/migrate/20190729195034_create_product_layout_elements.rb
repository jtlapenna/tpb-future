class CreateProductLayoutElements < ActiveRecord::Migration[5.2]
  def change
    create_table :product_layout_elements do |t|
      t.references :product_layout_tab, foreign_key: true
      t.integer :element_type
      t.string :coord_x
      t.string :coord_y
      t.string :hint

      t.timestamps
    end
  end
end
