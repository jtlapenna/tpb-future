class CreateCatalogSyncItems < ActiveRecord::Migration[5.1]
  def change
    create_table :catalog_sync_items do |t|
      t.references :catalog_sync, foreign_key: true
      t.text :fields

      t.timestamps
    end
  end
end
