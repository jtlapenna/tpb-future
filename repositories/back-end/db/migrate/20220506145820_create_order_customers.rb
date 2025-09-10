class CreateOrderCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :order_customers do |t|
      t.string :uuid, null: false
      t.integer :client_id, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.references :kiosks , foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.datetime :date, null:true
      t.boolean :payed, null: false
      t.timestamps
    end
  end
  def down
    drop_table :order_customers
  end
end
