class CreateCatalogSyncs < ActiveRecord::Migration[5.1]
  def change
    create_table :catalog_syncs do |t|
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
