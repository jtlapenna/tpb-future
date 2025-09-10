class CreateJoinTablePurchaseLimitStoreCategory < ActiveRecord::Migration[6.0]
  def change
    create_join_table :purchase_limits, :store_categories do |t|
      t.index [:purchase_limit_id, :store_category_id], name: 'puchase_limit_store_categories_join_table'
      t.index [:store_category_id, :purchase_limit_id], name: 'store_categories_puchase_limit_join_table'
    end
  end
end
