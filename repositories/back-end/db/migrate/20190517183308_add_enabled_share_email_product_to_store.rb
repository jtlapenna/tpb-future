class AddEnabledShareEmailProductToStore < ActiveRecord::Migration[5.2]
  def change
    add_column :stores, :enabled_share_email_product, :boolean, default: false
  end
end
