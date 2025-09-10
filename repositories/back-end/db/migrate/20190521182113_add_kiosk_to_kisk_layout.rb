class AddKioskToKiskLayout < ActiveRecord::Migration[5.2]
  def change
    add_reference :kiosk_layouts, :kiosk, foreign_key: true
  end
end
