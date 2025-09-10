class CreateProductLayoutValues < ActiveRecord::Migration[5.2]
  def change
    create_table :product_layout_values do |t|
      t.references :product_layout_element, foreign_key: true
      t.references :kiosk_product, foreign_key: true
      t.string :link
      t.text :content

      t.timestamps
    end
  end
end
