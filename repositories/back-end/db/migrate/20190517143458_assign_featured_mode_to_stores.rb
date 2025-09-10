class AssignFeaturedModeToStores < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE stores
        SET featured_mode = (
          SELECT featured_mode FROM catalogs
          WHERE catalogs.store_id = stores.id
          LIMIT 1
        )
      SQL
    )
  end
end
