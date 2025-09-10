class AddStoreToCatalogSync < ActiveRecord::Migration[5.2]
  def change
    add_reference :catalog_syncs, :store, foreign_key: true
  end
end
