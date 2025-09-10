class CreateWelcomeAssets < ActiveRecord::Migration[5.1]
  def change
    create_table :welcome_assets do |t|
      t.integer :store_id
      t.integer :asset_position_id

      t.timestamps
    end
  end
end
