class AddAdvertisableToAdBanners < ActiveRecord::Migration[6.0]
  def change
    add_reference :ad_banners, :advertisable, polymorphic: true, null: true
  end
end
