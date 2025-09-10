class CreateProductLayoutTabs < ActiveRecord::Migration[5.2]
  def change
    create_table :product_layout_tabs do |t|
      t.references :product_layout, foreign_key: true
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
