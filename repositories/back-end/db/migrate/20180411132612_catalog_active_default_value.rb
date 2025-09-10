class CatalogActiveDefaultValue < ActiveRecord::Migration[5.1]
  def change
    change_column :catalogs, :active, :boolean, default: true
  end
end
