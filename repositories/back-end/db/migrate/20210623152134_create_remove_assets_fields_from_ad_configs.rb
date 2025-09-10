class CreateRemoveAssetsFieldsFromAdConfigs < ActiveRecord::Migration[6.0]
  def change
    remove_column :ad_configs, :asset_url
    remove_column :ad_configs, :asset_type
  end
end
