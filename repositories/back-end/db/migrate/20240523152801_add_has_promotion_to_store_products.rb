class AddHasPromotionToStoreProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :store_products, :has_promotion, :boolean, default: false
  end
end
