class AddCodeNameToAdBannerLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :ad_banner_locations, :codename, :string, unique: true
  end
end
