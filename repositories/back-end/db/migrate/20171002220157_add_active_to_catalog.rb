class AddActiveToCatalog < ActiveRecord::Migration[5.1]
  def change
    add_column :catalogs, :active, :boolean, default: false
  end
end
