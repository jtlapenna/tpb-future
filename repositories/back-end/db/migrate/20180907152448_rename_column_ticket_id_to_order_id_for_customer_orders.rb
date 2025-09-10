class RenameColumnTicketIdToOrderIdForCustomerOrders < ActiveRecord::Migration[5.1]
  def change
    rename_column :customer_orders, :ticket_id, :order_id
  end
end
