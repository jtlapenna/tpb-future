class UpdateValuableTypeOnProductValues < ActiveRecord::Migration[5.2]
  def change
    execute(
      <<-SQL
        UPDATE product_values
        SET valuable_type = 'StoreProduct'
        WHERE valuable_type = 'CatalogProduct'
      SQL
    )
  end
end
