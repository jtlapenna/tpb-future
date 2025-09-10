class AddIsFullScreenVideoToStoreProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :store_products, :is_full_screen, :boolean, default: false
  end
end
