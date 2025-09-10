class AddAccessTokenToStores < ActiveRecord::Migration[6.0]
  def change
    add_column :stores, :access_token, :string
  end
end
