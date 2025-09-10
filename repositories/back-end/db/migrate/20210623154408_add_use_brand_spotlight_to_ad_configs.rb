class AddUseBrandSpotlightToAdConfigs < ActiveRecord::Migration[6.0]
  def change
    add_column :ad_configs, :use_brand_spotlight, :boolean, default: false
  end
end
