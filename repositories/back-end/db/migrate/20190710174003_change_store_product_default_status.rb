class ChangeStoreProductDefaultStatus < ActiveRecord::Migration[5.2]
  def up
    change_column :store_products, :status, :integer, default: 1
  end

  def down
    change_column :store_products, :status, :integer, default: 0
  end
end
