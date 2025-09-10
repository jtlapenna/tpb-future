class ChangeSyncSettingsToApiSettings < ActiveRecord::Migration[5.1]
  class Catalog < ApplicationRecord
    store :sync_settings, coder: JSON
    store :api_settings, coder: JSON
  end

  def up
    rename_column :catalogs, :sync_settings, :api_settings

    Catalog.reset_column_information

    Catalog.find_each do |c|
      type = c.api_settings["sync_type"]
      c.api_settings = c.api_settings.except("sync_type").merge(api_type: type)

      c.update_column(:api_settings, c.api_settings)
    end
  end

  def down
    rename_column :catalogs, :api_settings, :sync_settings

    Catalog.reset_column_information

    Catalog.find_each do |c|
      type = c.sync_settings["sync_type"]
      c.sync_settings = c.sync_settings.except("sync_type").merge(api_type: type)

      c.update_column(:sync_settings, c.sync_settings)
    end
  end
end
