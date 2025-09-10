class AddFeaturedToCatalog < ActiveRecord::Migration[5.2]
  def change
    add_column :catalogs, :featured_mode, :integer, default: 0
  end
end
