class AddCatalogToCatalogSync < ActiveRecord::Migration[5.1]
  def change
    add_reference :catalog_syncs, :catalog, foreign_key: true
  end
end
