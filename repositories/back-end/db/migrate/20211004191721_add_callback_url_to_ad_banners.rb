class AddCallbackUrlToAdBanners < ActiveRecord::Migration[6.0]
  def change
    add_column :ad_banners, :callback_url, :string
  end
end
