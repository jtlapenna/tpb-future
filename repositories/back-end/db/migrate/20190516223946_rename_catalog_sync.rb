class RenameCatalogSync < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalog_syncs, :store_syncs
  end
end
