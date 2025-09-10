class CreateStoreCategoryKioskLayouts < ActiveRecord::Migration[6.0]
  def change
    create_table :store_category_kiosk_layouts do |t|
      t.references :store_category, null: false, foreign_key: true
      t.references :kiosk_layout, null: false, foreign_key: true

      t.timestamps
    end
  end
end
