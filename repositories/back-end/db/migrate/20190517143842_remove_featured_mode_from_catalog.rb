class RemoveFeaturedModeFromCatalog < ActiveRecord::Migration[5.2]
  def change
    remove_column :catalogs, :featured_mode
  end
end
