class AddNotificationSettingsToCatalog < ActiveRecord::Migration[5.1]
  def change
    add_column :catalogs, :notification_settings, :text
  end
end
