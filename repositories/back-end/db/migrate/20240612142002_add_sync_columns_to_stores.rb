class AddSyncColumnsToStores < ActiveRecord::Migration[6.0]
  def change
    add_column :stores, :last_sync_update, :string
    add_column :stores, :next_initial_sync, :string
  end
end
