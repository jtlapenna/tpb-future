class AddShareEmailTemplateToCatalogProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :catalog_products, :share_email_template, :string
  end
end
