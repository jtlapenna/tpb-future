class AddDisableOverlayMaskTokiosklayouts < ActiveRecord::Migration[6.0]
  def change
    add_column :kiosk_layouts, :disable_overlay_mask, :boolean, default: false
  end
end
