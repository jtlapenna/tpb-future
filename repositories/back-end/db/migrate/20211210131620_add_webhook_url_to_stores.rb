class AddWebhookUrlToStores < ActiveRecord::Migration[6.0]
  def change
    add_column :stores, :webhook_url, :json

    Store.all.each{ |store| store.update_column :webhook_url, store.webhook_endpoint }
  end
end
