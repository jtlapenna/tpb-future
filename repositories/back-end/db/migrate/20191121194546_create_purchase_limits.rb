class CreatePurchaseLimits < ActiveRecord::Migration[6.0]
  def change
    create_table :purchase_limits do |t|
      t.belongs_to :store_setting, foreign_key: true
      t.decimal :limit, null: false, precision: 8, scale: 3 
      t.string :name

      t.timestamps
    end
  end
end
