class CreateExpiredKioskProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :expired_kiosk_products do |t|

      t.references :kiosk, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true

      t.string :store_product_id
      t.datetime :expired_at
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
