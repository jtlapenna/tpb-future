class ChangeTaxIntoStoreCategory < ActiveRecord::Migration[6.0]
  def change
    change_column :store_categories, :tax, :text
  end
end
