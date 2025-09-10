class UpdateAssetSourceType < ActiveRecord::Migration[5.2]
  def change
    execute(
      <<-SQL
        UPDATE assets
        SET source_type = 'StoreProduct'
        WHERE source_type = 'CatalogProduct'
      SQL
    )

    execute(
      <<-SQL
        UPDATE assets
        SET source_type = 'KioskAsset'
        WHERE source_type = 'StoreAsset'
      SQL
    )
  end
end
