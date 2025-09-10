class AddIndexCustomerIdAndActiveToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_index :customers, [:customer_id, :status]
  end
end
