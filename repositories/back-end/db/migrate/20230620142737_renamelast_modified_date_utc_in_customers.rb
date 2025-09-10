class RenamelastModifiedDateUtcInCustomers < ActiveRecord::Migration[6.0]
  def change
    rename_column :customers, :lastModifiedDateUTC, :last_modified_date_utc
  end
end
