class ChangeTaxIntoStore < ActiveRecord::Migration[6.0]
  def change
    change_column :stores, :tax, :text
  end
end
