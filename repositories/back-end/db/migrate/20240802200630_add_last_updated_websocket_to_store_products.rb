class AddLastUpdatedWebsocketToStoreProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :store_products, :last_updated_websocket, :datetime
  end
end
