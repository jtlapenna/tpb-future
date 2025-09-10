class AddTaxToStoreCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :store_categories, :tax, :float
  end
end
