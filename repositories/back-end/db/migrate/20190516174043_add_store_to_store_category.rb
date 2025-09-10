class AddStoreToStoreCategory < ActiveRecord::Migration[5.2]
  def change
    add_reference :store_categories, :store, foreign_key: true
  end
end
