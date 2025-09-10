class ChangePurchaseLimitAndProductWeightToInteger < ActiveRecord::Migration[6.0]
  def up
    change_column :purchase_limits, :limit, :integer
    change_column :store_products, :weight, :integer
  end

  def down
    change_column :purchase_limits, :limit, :decimal, precision: 8, scale: 3
    change_column :store_products, :weight, :decimal, precision: 8, scale: 3
  end
end
