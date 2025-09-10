class CreateStoreLayouts < ActiveRecord::Migration[5.1]
  def change
    create_table :store_layouts do |t|
      t.integer :name, default: 0
      t.integer :store_id

      t.timestamps
    end
  end
end
