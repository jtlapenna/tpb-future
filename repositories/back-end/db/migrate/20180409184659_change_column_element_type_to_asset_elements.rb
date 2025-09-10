class ChangeColumnElementTypeToAssetElements < ActiveRecord::Migration[5.1]
  def change
    change_column :asset_elements, :element_type, :integer, using: 'element_type::integer'
    change_column_default :asset_elements, :element_type, from: nil, to: 0
  end
end
