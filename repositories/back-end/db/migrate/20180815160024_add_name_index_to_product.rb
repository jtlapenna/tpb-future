class AddNameIndexToProduct < ActiveRecord::Migration[5.1]
  def change
    add_index :products, "lower((name)::text) varchar_pattern_ops", name: :index_products_on_name
  end
end
