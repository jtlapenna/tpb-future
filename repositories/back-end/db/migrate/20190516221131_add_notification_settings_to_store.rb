class AddNotificationSettingsToStore < ActiveRecord::Migration[5.2]
  def change
    add_column :stores, :notification_settings, :text
  end
end
