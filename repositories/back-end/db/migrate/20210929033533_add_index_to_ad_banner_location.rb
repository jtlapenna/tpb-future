class AddIndexToAdBannerLocation < ActiveRecord::Migration[6.0]
  def change
    add_index :ad_banner_locations, :text, unique: true
  end
end
