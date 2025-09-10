class RemoveFeaturedFromStoreProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :store_products, :featured
  end
end
