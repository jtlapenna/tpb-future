class AddKioskIdToKioskProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :kiosk_products, :kiosk, foreign_key: true
  end
end
