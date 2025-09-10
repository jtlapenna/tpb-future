class AddProductLayoutToKioskLayout < ActiveRecord::Migration[5.2]
  def change
    add_reference :kiosk_layouts, :product_layout, foreign_key: true
  end
end
