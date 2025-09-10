class CreateDuplicatedSkuDeletedLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :duplicated_sku_deleted_logs do |t|
      t.string :deleted_sku
      t.string :deleted_store_product_id

      t.references :store, foreign_key: true
      t.references :store_product, foreign_key: true

      t.timestamps
    end
  end
end
