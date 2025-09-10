class RemoveNotificationSettingFromCatalog < ActiveRecord::Migration[5.2]
  def change
    remove_column :catalogs, :notification_settings
  end
end
