class AddWelcomeMessageToStoreLayouts < ActiveRecord::Migration[5.1]
  def change
    add_column :store_layouts, :welcome_message, :text
  end
end
