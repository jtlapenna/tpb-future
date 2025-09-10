class AddSettingsColumnsToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :general_settings, :text
  end
end
