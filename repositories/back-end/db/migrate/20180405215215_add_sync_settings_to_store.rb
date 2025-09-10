class AddSyncSettingsToStore < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :sync_settings, :text
  end
end
