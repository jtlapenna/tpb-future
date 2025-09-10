class AddColumnToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :lastModifiedDateUTC, :string
  end
end
