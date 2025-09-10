class AddStylesheetToKioskProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :kiosk_products, :stylesheet, :text
  end
end
