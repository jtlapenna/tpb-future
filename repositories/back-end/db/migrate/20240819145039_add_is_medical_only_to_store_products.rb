class AddIsMedicalOnlyToStoreProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :store_products, :is_medical_only, :boolean, default: false
  end
end
