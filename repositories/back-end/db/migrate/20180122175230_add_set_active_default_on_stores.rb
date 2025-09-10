class AddSetActiveDefaultOnStores < ActiveRecord::Migration[5.1]
  def change
    change_column_default :stores, :active, from: false, to: true

    Store.all.each{ |st| st.update_attribute :active, true }
  end
end
