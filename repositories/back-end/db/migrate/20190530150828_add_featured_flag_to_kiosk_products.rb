class AddFeaturedFlagToKioskProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :kiosk_products, :featured, :boolean, default: false
  end
end
