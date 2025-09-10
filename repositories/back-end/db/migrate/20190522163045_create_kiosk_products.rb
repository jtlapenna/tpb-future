class CreateKioskProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :kiosk_products do |t|
      t.references :store_product, foreign_key: true

      t.timestamps
    end
  end
end
