class AddLastestUpdateTokenToStoreProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :store_products, :latest_update_token, :string
  end
end
