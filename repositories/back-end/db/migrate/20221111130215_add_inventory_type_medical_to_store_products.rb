class AddInventoryTypeMedicalToStoreProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :store_products, :inventory_type_medical, :boolean, default: false
  end
end
