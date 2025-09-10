class AddApiKeyToCustomerSyncs < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_syncs, :external_account_id, :string
  end
end
