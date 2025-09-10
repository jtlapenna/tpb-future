class CreateLayoutsForExistentStores < ActiveRecord::Migration[5.1]
  def change
    Store.all.each { |store| store.create_layout! }
  end
end
