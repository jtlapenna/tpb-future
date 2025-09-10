class MoveTagsToStoreProduct < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE taggings
        SET taggable_type = 'StoreProduct'
        WHERE taggable_type = 'CatalogProduct'
      SQL
    )
  end
end
