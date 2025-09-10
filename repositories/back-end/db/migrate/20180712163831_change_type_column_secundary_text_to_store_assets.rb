class ChangeTypeColumnSecundaryTextToStoreAssets < ActiveRecord::Migration[5.1]
  def up
    change_column :store_assets, :secundary_text, :text
    rename_column :store_assets, :secundary_text, :secondary_text
  end

  def down
    rename_column :store_assets, :secondary_text, :secundary_text
    change_column :store_assets, :secundary_text, :string
  end
end
