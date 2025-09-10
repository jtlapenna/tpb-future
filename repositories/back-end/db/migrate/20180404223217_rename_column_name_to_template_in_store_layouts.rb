class RenameColumnNameToTemplateInStoreLayouts < ActiveRecord::Migration[5.1]
  def change
    rename_column :store_layouts, :name, :template
  end
end
