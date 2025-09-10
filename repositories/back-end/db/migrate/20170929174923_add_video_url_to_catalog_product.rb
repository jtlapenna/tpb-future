class AddVideoUrlToCatalogProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_products, :video_url, :string
  end
end
