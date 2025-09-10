class AddBlockSimultaneousNfcToStores < ActiveRecord::Migration[6.0]
  def change
    add_column :stores, :block_simultaneous_nfc, :boolean, null: true, default:false
  end
end
