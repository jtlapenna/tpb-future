class RenameCatalogs < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalogs, :kiosks
  end
end
