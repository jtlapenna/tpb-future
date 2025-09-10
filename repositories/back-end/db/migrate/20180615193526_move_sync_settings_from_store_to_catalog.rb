class MoveSyncSettingsFromStoreToCatalog < ActiveRecord::Migration[5.1]
  class Store < ApplicationRecord
    has_many :catalogs
  end

  class Catalog < ApplicationRecord
    belongs_to :store
  end

  def up
    add_column :catalogs, :sync_settings, :text

    Catalog.find_each do |catalog|
      catalog.update_columns(sync_settings: catalog.store.sync_settings)
    end

    remove_column :stores, :sync_settings
  end

  def down
    add_column :stores, :sync_settings, :text

    Store.find_each do |store|
      store.update_columns(sync_settings: store.catalogs.where.not(sync_settings: nil).first.sync_settings)
    end

    remove_column :catalogs, :sync_settings
  end
end
