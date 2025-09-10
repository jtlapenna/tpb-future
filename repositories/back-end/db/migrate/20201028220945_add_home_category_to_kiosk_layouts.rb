class AddHomeCategoryToKioskLayouts < ActiveRecord::Migration[6.0]
  def change
    add_reference :kiosk_layouts, :store_category, null: true, foreign_key: true
    add_column :kiosk_layouts, :on_sale_badges, :boolean
    add_column :kiosk_layouts, :checkout_text, :string
    add_column :kiosk_layouts, :pagination_time, :integer
  end
end
