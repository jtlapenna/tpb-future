class AddIndexStoreIdAndStatusToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_index :customers, 'store_id, lower(status)', name: :index_customers_on_store_id_and_status
  end
end
