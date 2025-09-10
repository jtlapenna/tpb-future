class AddIndexToCustomerPhone < ActiveRecord::Migration[6.0]
  def change
    add_index :customers, "REPLACE(REPLACE(REPLACE(REPLACE(phone, '-', ''), ' ', ''), '(', ''), ')', '')", name: :idx_customer_phone
  end
end
