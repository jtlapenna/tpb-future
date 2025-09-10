class RemoveGeneralSettingsFromStore < ActiveRecord::Migration[5.1]
  def change
    remove_column :stores, :general_settings, :text
  end
end
