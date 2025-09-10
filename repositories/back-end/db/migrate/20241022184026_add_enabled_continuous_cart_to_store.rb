class AddEnabledContinuousCartToStore < ActiveRecord::Migration[6.0]
  def change
    add_column :stores, :enabled_continuous_cart, :boolean, default: false
  end
end
