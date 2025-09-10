class CreateAdBanners < ActiveRecord::Migration[6.0]
  def change
    create_table :ad_banners do |t|
      t.string :text
      t.references :store, null: false, foreign_key: true
      t.references :ad_banner_location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
