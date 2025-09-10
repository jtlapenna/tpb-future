class RemoveEnabledShareEmailProductFromCatalog < ActiveRecord::Migration[5.2]
  def change
    remove_column :catalogs, :enabled_share_email_product
  end
end
