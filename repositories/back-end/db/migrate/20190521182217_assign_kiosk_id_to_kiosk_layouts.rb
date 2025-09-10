class AssignKioskIdToKioskLayouts < ActiveRecord::Migration[5.2]
  def change
    execute(
      <<-SQL
        UPDATE kiosk_layouts
        SET kiosk_id = (
          SELECT id FROM kiosks
          WHERE store_id = kiosk_layouts.store_id
          LIMIT 1
        )
      SQL
    )
  end
end
