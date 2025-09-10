class MoveStoreGeneralSettingsToStoreSettings < ActiveRecord::Migration[5.1]
  class Store < ApplicationRecord
    has_one :settings, class_name: StoreSetting.name
  end

  class StoreSetting < ApplicationRecord
    belongs_to :store, inverse_of: :settings
  end

  def up
    Store.find_each do |store|
      store.create_settings unless store.settings.present?
      store.settings.update_column(:data, store.general_settings)
    end
  end

  def down
    StoreSetting.find_each do |settings|
      settings.store.update_column(:general_settings, settings.data)
    end
  end
end
