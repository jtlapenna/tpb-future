class CreateStoreSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :store_settings do |t|
      t.integer :store_id
      t.text :data

      t.timestamps
    end

    add_index :store_settings, :store_id
    add_foreign_key :store_settings, :stores
  end
end
