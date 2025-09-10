class RenameColumnBirthdaydateToBirthdayToCustomers < ActiveRecord::Migration[5.2]
  def change
    rename_column :customers, :birthdaydate, :birthday
  end
end
