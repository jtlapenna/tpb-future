class MoveCatalogTagsToKiosk < ActiveRecord::Migration[5.2]
  def change
    execute(
      <<-SQL
        UPDATE taggings
        SET taggable_type = 'Kiosk'
        WHERE taggable_type = 'Catalog'
      SQL
    )
  end
end
