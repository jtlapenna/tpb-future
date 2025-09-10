class AddEnabledShareSmsProductToStore < ActiveRecord::Migration[5.2]
  def change
    add_column :stores, :enabled_share_sms_product, :boolean, default: false
  end
end
