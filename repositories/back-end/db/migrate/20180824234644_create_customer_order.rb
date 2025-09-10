class CreateCustomerOrder < ActiveRecord::Migration[5.1]
  def change
    create_table :customer_orders do |t|
      t.integer :customer_id
      t.string :ticket_id
      t.index ["customer_id"]

      t.timestamps
    end
  end
end
