class ChangeProductWeightToDecimal < ActiveRecord::Migration[6.0]
  def up
    change_column :store_products, :weight, :decimal
  end

  def down
    change_column :store_products, :weight, :integer
  end
end
