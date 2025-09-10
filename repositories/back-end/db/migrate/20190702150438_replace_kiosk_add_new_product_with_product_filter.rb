class ReplaceKioskAddNewProductWithProductFilter < ActiveRecord::Migration[5.2]
  def up
    add_column :kiosks, :product_filter_criteria, :integer, default: 0
    add_reference :kiosks, :product_filter_value, polymorphic: true, index: { name: 'index_kiosks_on_product_filter_value' }

    add_index :kiosks, [:product_filter_criteria, :product_filter_value_type, :product_filter_value_id], name: :index_kiosks_product_filter_criteria

    execute("UPDATE kiosks SET product_filter_criteria = 1 WHERE auto_add_new_products = true")

    remove_column :kiosks, :auto_add_new_products
  end

  def down
    add_column :kiosks, :auto_add_new_products, :boolean, default: false

    execute("UPDATE kiosks SET auto_add_new_products = true WHERE product_filter_criteria = 1")

    remove_index :kiosks, [:product_filter_criteria, :product_filter_value_type, :product_filter_value_id]
    remove_column :kiosks, :product_filter_criteria
    remove_reference :kiosks, :product_filter_value, polymorphic: true, index: { name: 'index_kiosks_on_product_filter_value' }
  end
end
