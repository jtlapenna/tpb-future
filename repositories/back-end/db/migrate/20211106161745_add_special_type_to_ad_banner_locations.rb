class AddSpecialTypeToAdBannerLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :ad_banner_locations, :special_type, :string, null: true, unique: true
  end
end
