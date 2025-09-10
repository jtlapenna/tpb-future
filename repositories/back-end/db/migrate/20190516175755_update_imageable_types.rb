class UpdateImageableTypes < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE images
        SET imageable_type = 'StoreProduct'
        WHERE imageable_type = 'CatalogProduct'
      SQL
    )
  end

  def down

  end
end
