class CreateCustomerSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_syncs do |t|
      t.integer :status, default: 0
      t.bigint :store_id

      t.timestamps
    end
  end
end
