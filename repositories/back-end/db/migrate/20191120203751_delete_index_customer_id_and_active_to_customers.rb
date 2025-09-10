class DeleteIndexCustomerIdAndActiveToCustomers < ActiveRecord::Migration[6.0]
  def change
    remove_index :customers, [:customer_id, :status]
  end
end
