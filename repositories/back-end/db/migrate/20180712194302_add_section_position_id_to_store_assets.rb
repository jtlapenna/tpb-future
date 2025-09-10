class AddSectionPositionIdToStoreAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :store_assets, :section_position_id, :integer, default: 10 # fullscreen layout position
  end
end
