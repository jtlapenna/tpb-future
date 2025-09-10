class AssignNotificationSettingsToStore < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE stores
        SET notification_settings = (
          SELECT notification_settings FROM catalogs
          WHERE catalogs.store_id = stores.id
        )
      SQL
    )
  end
end
