class CreateBrandAndStoreCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :brand_and_store_categories do |t|
      t.references :brand, null: false, foreign_key: true
      t.references :store_category, null: false, foreign_key: true
      t.references :kiosk, null: false, foreign_key: true

      t.timestamps
    end

    add_index :brand_and_store_categories, [:brand_id, :store_category_id], unique: true, name: 'index_brand_and_store'
  end
end
