class CreateAdConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :ad_configs do |t|
      t.string :name
      t.belongs_to :kiosk, foreign_key: true
      t.belongs_to :kiosk_product, foreign_key: true
      t.belongs_to :brand, foreign_key: true
      t.string :asset_url
      t.bigint :asset_type
      t.timestamps
    end    
  end
end
