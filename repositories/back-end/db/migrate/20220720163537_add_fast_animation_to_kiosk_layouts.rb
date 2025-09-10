class AddFastAnimationToKioskLayouts < ActiveRecord::Migration[6.0]
  def change
    add_column :kiosk_layouts, :fast_animation, :boolean, default: false
  end
end
