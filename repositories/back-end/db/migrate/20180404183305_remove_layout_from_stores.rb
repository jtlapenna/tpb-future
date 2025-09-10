class RemoveLayoutFromStores < ActiveRecord::Migration[5.1]
  def change
    remove_column :stores, :layout, :integer
  end
end
