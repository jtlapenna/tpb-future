class CreateRfidProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :rfid_products do |t|
      t.string :rfid
      t.bigint :catalog_id
      t.belongs_to :catalog_product, foreign_key: true

      t.timestamps
    end

    add_index :rfid_products, :catalog_id
  end
end
