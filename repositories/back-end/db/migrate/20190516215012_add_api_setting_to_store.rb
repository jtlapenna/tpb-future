class AddApiSettingToStore < ActiveRecord::Migration[5.2]
  def change
    add_column :stores, :api_settings, :text
  end
end
