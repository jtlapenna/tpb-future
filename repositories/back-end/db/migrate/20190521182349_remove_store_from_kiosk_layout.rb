class RemoveStoreFromKioskLayout < ActiveRecord::Migration[5.2]
  def change
    remove_column :kiosk_layouts, :store_id
  end
end
