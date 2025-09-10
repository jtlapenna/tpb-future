class CreateCustomerOrderStoreProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_order_store_products do |t|
      t.references :order_customers, foreign_key: true
      t.references :store_products, foreign_key: true
      t.integer :product_value_id , null: true
      t.integer :quantity , null: false
      t.timestamps
    end
  end
  def down
    drop_table :customer_order_store_products
  end
end