class RenameStoreLayoutOnLayoutNavigation < ActiveRecord::Migration[5.2]
  def change
    rename_column :layout_navigations, :store_layout_id, :kiosk_layout_id
  end
end
