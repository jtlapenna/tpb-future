class SetValueDefaultForFeaturedCatalog < ActiveRecord::Migration[5.2]
  class Catalog < ApplicationRecord
    store :sync_settings, coder: JSON
    store :api_settings, coder: JSON
  end
  def up
    Catalog.update_all(featured_mode: 0)
  end
end
