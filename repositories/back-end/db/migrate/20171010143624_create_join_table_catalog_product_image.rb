class CreateJoinTableCatalogProductImage < ActiveRecord::Migration[5.1]
  def change
    create_join_table :catalog_products, :images do |t|
      t.index [:catalog_product_id, :image_id], name: 'catalog_product_image_join_table'
      t.index [:image_id, :catalog_product_id], name: 'image_catalog_product_join_table'
    end
  end
end
