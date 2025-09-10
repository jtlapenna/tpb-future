class RemoveVideoUrlField < ActiveRecord::Migration[5.1]
  def change
    remove_column :catalog_products, :video_url
    remove_column :product_variants, :video_url
    remove_column :products, :video_url
  end
end
