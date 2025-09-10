class AddShareSmsTemplateToStoreProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :store_products, :share_sms_template, :string
  end
end
