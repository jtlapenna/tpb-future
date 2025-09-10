class RemoveApiSettingsFromCatalog < ActiveRecord::Migration[5.2]
  def change
    remove_column :catalogs, :api_settings
  end
end
