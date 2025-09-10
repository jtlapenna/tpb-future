class AddHomeLayoutToStoreLayouts < ActiveRecord::Migration[5.1]
  def change
    add_column :store_layouts, :home_layout, :integer
  end
end
