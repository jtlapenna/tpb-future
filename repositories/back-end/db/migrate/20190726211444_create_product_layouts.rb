class CreateProductLayouts < ActiveRecord::Migration[5.2]
  def change
    create_table :product_layouts do |t|
      t.string :name

      t.timestamps
    end

    add_index :product_layouts, 'lower(name)', name: :index_product_layouts_on_name, unique: true
  end
end
