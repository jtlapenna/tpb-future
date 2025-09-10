class AddPrintedDateAndPrintedIdToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :printed_date, :datetime, null: true
    add_column :customer_orders, :printed_id, :string, null: true
  end
end
