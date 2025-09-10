class AddDataToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :data, :text, null: true
  end
end
