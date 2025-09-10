class ChangeStoreLayoutStringToInteger < ActiveRecord::Migration[5.1]
  def up
    change_column :stores, :layout, :integer, using: 'layout::integer'
    change_column_default :stores, :layout, from: nil, to: 0
  end
  def dow
    change_column :stores, :layout, :string, using: 'layout::string'
    change_column_default :stores, :layout, from: 0, to: nil
  end
end
