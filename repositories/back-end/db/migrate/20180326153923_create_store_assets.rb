class CreateStoreAssets < ActiveRecord::Migration[5.1]
  def change
    create_table :store_assets do |t|
      t.string :text
      t.string :secundary_text
      t.integer :text_position_id
      t.integer :asset_position_id
      t.string :layout

      t.timestamps
    end
  end
end
