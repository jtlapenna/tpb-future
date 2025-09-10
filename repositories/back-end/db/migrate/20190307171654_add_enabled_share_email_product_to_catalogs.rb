class AddEnabledShareEmailProductToCatalogs < ActiveRecord::Migration[5.2]
  def change
    add_column :catalogs, :enabled_share_email_product, :boolean, default: false
  end
end
