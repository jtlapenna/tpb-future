class CreateAdBannerLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :ad_banner_locations do |t|
      t.string :text

      t.timestamps
    end
  end
end
