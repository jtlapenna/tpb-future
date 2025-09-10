class AddDisabledToAdBanners < ActiveRecord::Migration[6.0]
  def change
    add_column :ad_banners, :disabled, :boolean, default: false
  end
end
