class AssignFeaturedToKioskProducts < ActiveRecord::Migration[5.2]
  def change
    execute(
      <<-SQL
        UPDATE kiosk_products
        SET featured = (
          SELECT featured FROM store_products
          WHERE id = kiosk_products.store_product_id
        )
      SQL
    )
  end
end
