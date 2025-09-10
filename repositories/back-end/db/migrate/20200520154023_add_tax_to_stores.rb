class AddTaxToStores < ActiveRecord::Migration[6.0]
  def change
    add_column :stores, :tax, :float
  end
end
