class AddColumnOrderToStoreCategoryKioskLayouts < ActiveRecord::Migration[6.0]
  def change
    add_column :store_category_kiosk_layouts, :order, :integer
  end
end
