class AddAutoAddNewProductsToKiosk < ActiveRecord::Migration[5.2]
  def change
    add_column :kiosks, :auto_add_new_products, :boolean, default: false
  end
end
