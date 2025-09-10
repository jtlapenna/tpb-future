class AddLatestUpdateSourceToStoreProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :store_products, :latest_update_source, :string
  end
end
