class AddApiKeyToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :external_account_id, :string
  end
end
