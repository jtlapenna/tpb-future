class CreateKioskProductsFromStore < ActiveRecord::Migration[5.2]
  def change
    execute(
      <<-SQL
        INSERT INTO kiosk_products(store_product_id, kiosk_id, created_at, updated_at)
          SELECT store_products.id as store_product_id,
                 kiosks.id as kiosk_id,
                 current_timestamp as created_at,
                 current_timestamp as updated_at
          FROM store_products
          INNER JOIN kiosks ON kiosks.store_id = store_products.store_id
      SQL
    )
  end
end
