class AssignApiSettingsToStore < ActiveRecord::Migration[5.2]
  def change
    execute(
      <<-SQL
        UPDATE stores
        SET api_settings = (
          SELECT api_settings FROM catalogs
          WHERE catalogs.store_id = stores.id
        )
      SQL
    )
  end
end
